#!/usr/bin/env python3
"""Write every WireGuard client's config, built from Vaultwarden (via rbw) and the router's vars."""
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


def rbw(*args) -> list | dict:
    """Run rbw and return its parsed JSON output."""
    return json.loads(subprocess.run(["rbw", *args], check=True, capture_output=True, text=True).stdout)


def rbw_entry(*args) -> dict:
    """Return an entry's password and custom fields."""
    raw = rbw("get", "--raw", *args)
    return {"password": raw["data"]["password"], **{f["name"]: f["value"] for f in raw["fields"]}}


def config(v, client, endpoint, full_tunnel) -> str:
    """Render the client config for one device."""
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
    parser.add_argument("--full-tunnel", action="store_true", help="route all traffic through home")
    args = parser.parse_args()
    v = router_vars()
    endpoint = rbw_entry(ENTRY_ENDPOINT)
    clients = [entry for entry in rbw("list", "--raw") if entry["name"].lower() == ENTRY_CLIENT.lower()]
    OUTPUT.mkdir(exist_ok=True)
    failed = 0
    for entry in clients:
        device = entry.get("user") or entry["id"]
        client = rbw_entry(entry["id"])
        if not client.get("password") or not client.get("IP"):
            print(f"{device}: missing private key or IP, skipped", file=sys.stderr)
            failed += 1
            continue
        conf = config(v, client, endpoint, args.full_tunnel)
        # The file name becomes the interface name on import, so keep it short and plain.
        path = OUTPUT / f"{re.sub(r'[^a-z0-9]+', '-', device.lower()).strip('-')}.conf"
        path.touch(mode=0o600)
        path.write_text(conf)
        print(f"\n{device}: {path.relative_to(ROOT)}")
        failed += subprocess.run(["qrencode", "-t", "ansiutf8"], input=conf, text=True, check=False).returncode != 0
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
