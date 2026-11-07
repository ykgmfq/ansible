# router_wan

IPv4/IPv6 WAN connectivity for the OpenWRT router, carried over from the router it replaces.

## Purpose

Gives everything else on the router a working uplink.
It runs while the router is still at the factory-default LAN address, so WAN can be verified before the router claims the production subnet.

## Rationale

**Plain DHCP.** A separate modem owns the DSL/PPPoE session; the router only sees a plain Ethernet handoff, so no PPPoE credentials are involved.
