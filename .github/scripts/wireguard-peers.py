#!/usr/bin/env python3
"""Print WireGuard peers from Vaultwarden (via rbw) as JSON for `wireguard_peers`."""
import json
import subprocess
import sys

ENTRY_NAME = "wireguard client"
FIELDS = {"public_key": "Public key", "ip": "IP"}


def rbw(*args) -> list | dict:
    """Run rbw and return its parsed JSON output."""
    return json.loads(subprocess.run(["rbw", *args], check=True, capture_output=True, text=True).stdout)


def main() -> int:
    peers, errors = [], []
    for entry in rbw("list", "--raw"):
        if entry["name"].lower() != ENTRY_NAME:
            continue
        fields = {f["name"]: f["value"] for f in rbw("get", "--raw", entry["id"])["fields"]}
        peer = {key: fields.get(name) for key, name in FIELDS.items()}
        missing = [FIELDS[key] for key, value in peer.items() if not value]
        if missing:
            errors.append(f"{entry['name']} / {entry.get('user')}: missing {', '.join(missing)}")
        peers.append(peer)
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(json.dumps(peers))
    return 0


if __name__ == "__main__":
    sys.exit(main())
