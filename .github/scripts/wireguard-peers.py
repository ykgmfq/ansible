#!/usr/bin/env python3
"""Print WireGuard peers from Vaultwarden (via rbw) as JSON for `wireguard_peers`."""
import json
import sys

from vaultwarden import entries, missing

ENTRY_CLIENT = "WireGuard Client"
FIELDS = {"public_key": "Public key", "ip": "IP"}
# Optional comma-separated subnets behind a site-to-site peer.
FIELD_NETWORKS = "Networks"


def main() -> int:
    clients = entries(ENTRY_CLIENT)
    # Fail on any bad entry rather than emit a partial list, which would drop that peer from the router.
    errors = [error for device, client in clients if (error := missing(device, client, FIELDS.values()))]
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    peers = [
        {
            "name": device,
            **{key: client[name] for key, name in FIELDS.items()},
            "networks": [net.strip() for net in (client.get(FIELD_NETWORKS) or "").split(",") if net.strip()],
        }
        for device, client in clients
    ]
    print(json.dumps(peers))
    return 0


if __name__ == "__main__":
    sys.exit(main())
