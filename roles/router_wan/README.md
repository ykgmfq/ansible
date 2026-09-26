# router_wan

IPv4/IPv6 WAN connectivity for the new OpenWRT router, carried over from the router it replaces.

## Purpose

Gets the router talking to the modem so everything else in the `router` group (WireGuard, DDNS, DNS-over-TLS, HTTPS passthrough) has a working uplink. This runs from `playbooks/network.yml` while the router is still reachable at OpenWRT's factory-default LAN address, so WAN can be verified before the router ever claims the production LAN subnet — see `roles/router_lan`.

## Rationale

**Plain DHCP.** A separate modem now owns the DSL/PPPoE session; the router only ever sees a plain Ethernet handoff, so WAN is `proto dhcp` for IPv4 and `proto dhcpv6` (requesting whatever prefix length the ISP delegates) for IPv6 — no PPPoE credentials involved.
