# router_ddns

Keeps the router's own public DNS record (`pöpperl.eu`, apex) pointed at its current IPv6 address.

## Purpose

The router — not the homeserver — now owns the address WireGuard clients connect to, so it needs its own dynamic-DNS updater. This is OpenWRT's equivalent of the homeserver's `roles/dyndns`: same idea (Strato, dyndns2 protocol), different mechanism, because the target OS is different (`ddns-scripts` + UCI instead of a systemd timer + fish script).

## Rationale

**Apex domain, not a subdomain.** `pöpperl.eu` itself is kept current, matching how the domain was used on the previously-active router.
