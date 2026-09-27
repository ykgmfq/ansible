#!/usr/bin/env python3
"""Write a WireGuard client config built from Vaultwarden (via rbw) and the router's vars."""
import argparse
import ipaddress
import json
import re
import subprocess
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "output"
ENTRY_CLIENT = "Wireguard Client"
ENTRY_ENDPOINT = "WireGuard Endpoint"


def load(path) -> dict:
    """Return a YAML file's contents, or an empty dict if it doesn't exist."""
    if not path.exists():
        return {}
    data = yaml.safe_load(path.read_text())
    return {} if data is None else data


def router_vars() -> dict:
    """Merge the role defaults with the router group_vars, which win."""
    roles = [load(ROOT / f"roles/{role}/defaults/main.yml") for role in ("wireguard", "router_lan")]
    return {k: v for d in (*roles, load(ROOT / "group_vars/router/main.yml")) for k, v in d.items()}


def rbw_entry(*args) -> dict:
    """Return an entry's password and custom fields."""
    raw = json.loads(subprocess.run(["rbw", "get", "--raw", *args], check=True, capture_output=True, text=True).stdout)
    return {"password": raw["data"]["password"], **{f["name"]: f["value"] for f in raw["fields"]}}


def config(device, full_tunnel) -> str:
    """Render the client config for one device."""
    v = router_vars()
    client = rbw_entry(ENTRY_CLIENT, device)
    endpoint = rbw_entry(ENTRY_ENDPOINT)
    if full_tunnel:
        allowed = "0.0.0.0/0, ::/0"
    else:
        tunnel = ipaddress.ip_interface(v["wireguard_address"]).network
        lan = ipaddress.ip_interface(f"{v['router_lan_ipaddr']}/{v['router_lan_netmask']}").network
        allowed = f"{tunnel}, {lan}"
    return (
        "[Interface]\n"
        f"PrivateKey = {client['password']}\n"
        f"Address = {client['IP']}\n"
        f"DNS = {v['router_lan_ipaddr']}\n"
        "\n"
        "[Peer]\n"
        f"PublicKey = {endpoint['Public key']}\n"
        f"Endpoint = {v['router_ddns_domain']}:{v['wireguard_listen_port']}\n"
        f"AllowedIPs = {allowed}\n"
        # Keeps NAT mappings on the client's side open so the router can reach it.
        "PersistentKeepalive = 25\n"
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("device", help=f"username of the '{ENTRY_CLIENT}' entry, e.g. 'iphone Dennis'")
    parser.add_argument("--full-tunnel", action="store_true", help="route all traffic through home")
    parser.add_argument("--qr", action="store_true", help="print as a terminal QR code for mobile import")
    args = parser.parse_args()
    conf = config(args.device, args.full_tunnel)
    # The file name becomes the interface name on import, so keep it short and plain.
    path = OUTPUT / f"{re.sub(r'[^a-z0-9]+', '-', args.device.lower()).strip('-')}.conf"
    OUTPUT.mkdir(exist_ok=True)
    path.touch(mode=0o600)
    path.write_text(conf)
    print(path.relative_to(ROOT))
    if args.qr:
        return subprocess.run(["qrencode", "-t", "ansiutf8"], input=conf, text=True, check=False).returncode
    return 0


if __name__ == "__main__":
    sys.exit(main())
