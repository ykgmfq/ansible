# homeserver_passthrough

Firewall rules letting inbound web and SSH traffic reach the homeserver directly.

## Purpose

The homeserver terminates its own TLS and is directly reachable over IPv6, so no NAT66 is configured, only a forwarding opening from the internet-facing zone to the LAN.
A separate role because it is ingress for a different host than the router's own services.

## Rationale

**Matched on the interface identifier, not the full address.** A rule on the full destination address silently stops working when the ISP delegates a new prefix, since only the host part of the homeserver's address is stable.
The rules therefore match the lower half of the destination address.

The identifier is deployment-specific and comes from the personal inventory.
It only changes if the homeserver's network card does.
