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


def valid_entries() -> tuple[list[dict], list[str]]:
    """Return client entries' custom fields, plus an error for each entry missing a required one."""
    entries, errors = [], []
    clients = [entry for entry in rbw("list", "--raw") if entry["name"].lower() == ENTRY_NAME]
    for entry in clients:
        fields = {f["name"]: f["value"] for f in rbw("get", "--raw", entry["id"])["fields"]}
        missing = [name for name in FIELDS.values() if not fields.get(name)]
        if missing:
            errors.append(f"{entry['name']} / {entry.get('user')}: missing {', '.join(missing)}")
        else:
            entries.append(fields)
    return entries, errors


def main() -> int:
    entries, errors = valid_entries()
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(json.dumps([{key: fields[name] for key, name in FIELDS.items()} for fields in entries]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
