#!/usr/bin/env python3
"""Update the Strato AAAA record for this host's current global IPv6 address.

Run via `systemctl start strato-dyndns.service`, not directly: the unit provides
STRATO_DYNDNS_USER / STRATO_DYNDNS_HOST in the environment and the DynDNS
password as the systemd "strato-password" credential.
"""

import argparse
import base64
import ipaddress
import json
import os
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import NoReturn

CACHE_FILE = Path("/var/lib/strato-dyndns/last-ip")
UPDATE_URL = "https://dyndns.strato.com/nic/update"


def fail(message: str) -> NoReturn:
    print(f"strato-dyndns: {message}", file=sys.stderr)
    raise SystemExit(1)


def current_ipv6() -> str:
    """Return the stable, routable global IPv6 address of this host.

    Skips temporary privacy, deprecated, and tentative addresses, plus any
    non-global-unicast address (e.g. ULA), so the record points at the address
    used for inbound connections.
    """
    output = subprocess.run(
        ["ip", "-6", "-json", "addr", "show", "scope", "global"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    flags = ("temporary", "deprecated", "tentative", "dadfailed")
    for link in json.loads(output):
        for addr in link.get("addr_info", []):
            if any(addr.get(flag) for flag in flags):
                continue
            ip = ipaddress.ip_address(addr["local"])
            if ip.version == 6 and ip.is_global:
                return str(ip)
    fail("no global IPv6 address found")


def password() -> str:
    creds = os.environ.get("CREDENTIALS_DIRECTORY")
    cred_file = Path(creds, "strato-password") if creds else None
    if cred_file is None or not cred_file.is_file():
        fail("password credential unavailable; start via strato-dyndns.service")
    return cred_file.read_text().strip()


def update(user: str, host: str, secret: str, ipv6: str) -> str:
    query = urllib.parse.urlencode({"hostname": host, "myip": ipv6})
    request = urllib.request.Request(f"{UPDATE_URL}?{query}")
    token = base64.b64encode(f"{user}:{secret}".encode()).decode()
    request.add_header("Authorization", f"Basic {token}")
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return response.read().decode().strip()
    except urllib.error.URLError as error:
        fail(f"request failed: {error}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--force", action="store_true", help="update even when the address is unchanged"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="resolve the address and report the update without contacting Strato",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    user = os.environ.get("STRATO_DYNDNS_USER")
    if not user:
        fail("STRATO_DYNDNS_USER not set; start via strato-dyndns.service")
    host = os.environ.get("STRATO_DYNDNS_HOST", user)

    ipv6 = current_ipv6()

    # Skip unchanged updates to stay clear of Strato's abuse protection.
    if not args.force and CACHE_FILE.is_file() and CACHE_FILE.read_text().strip() == ipv6:
        print(f"strato-dyndns: {ipv6} unchanged, skipping")
        return

    if args.dry_run:
        print(f"strato-dyndns: would update {host} -> {ipv6}")
        return

    response = update(user, host, password(), ipv6)
    print(f"strato-dyndns: {host} -> {ipv6}: {response}")

    if response.split()[:1] in (["good"], ["nochg"]):
        CACHE_FILE.parent.mkdir(parents=True, exist_ok=True)
        CACHE_FILE.write_text(ipv6 + "\n")
    else:
        fail(f"update rejected: {response}")


if __name__ == "__main__":
    main()
