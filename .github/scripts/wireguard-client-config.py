#!/usr/bin/env python3
"""Write every WireGuard client's config, built from Vaultwarden (via rbw) and the router's vars."""
import argparse
import ipaddress
import os
import re
import subprocess
import sys
from pathlib import Path

import yaml

from vaultwarden import entries, entry, missing

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "output"
PERSONAL = Path(os.environ.get("PERSONAL_DIR", ROOT / "personal"))
ENTRY_CLIENT = "WireGuard Client"
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
    return {k: v for d in (*roles, load(PERSONAL / "group_vars/router/main.yml")) for k, v in d.items()}


def config(v, client, endpoint, full_tunnel) -> str:
    """Render the client config for one device."""
    if full_tunnel:
        allowed = "0.0.0.0/0, ::/0"
    else:
        tunnel = ipaddress.ip_interface(v["wireguard_address"]).network
        lan = ipaddress.ip_interface(f"{v['router_lan_ipaddr']}/{v['router_lan_netmask']}").network
        allowed = f"{tunnel}, {lan}"
    # PersistentKeepalive keeps NAT mappings on the client's side open so the router can reach it.
    return f"""\
[Interface]
PrivateKey = {client['password']}
Address = {client['IP']}
DNS = {v['router_lan_ipaddr']}

[Peer]
PublicKey = {endpoint['Public key']}
Endpoint = {v['router_ddns_domain']}:{v['wireguard_listen_port']}
AllowedIPs = {allowed}
PersistentKeepalive = 25
"""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--full-tunnel", action="store_true", help="route all traffic through home")
    args = parser.parse_args()
    v = router_vars()
    endpoint = entry(ENTRY_ENDPOINT)
    if error := missing(ENTRY_ENDPOINT, endpoint, ["Public key"]):
        print(error, file=sys.stderr)
        return 1
    OUTPUT.mkdir(exist_ok=True)
    failed = 0
    for device, client in entries(ENTRY_CLIENT):
        if error := missing(device, client, ["password", "IP"]):
            print(f"{error}, skipped", file=sys.stderr)
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
