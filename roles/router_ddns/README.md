# router_ddns

Keeps the router's own public DNS record (the apex domain) pointed at its current IPv6 address.

## Purpose

The router owns the address WireGuard clients connect to, so it needs its own dynamic-DNS updater.
Same idea as the homeserver's updater, different mechanism because the OS differs.
