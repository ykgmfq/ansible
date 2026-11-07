# router_firewall

Removes blanket internet-to-LAN forwarding rules from the router's firewall configuration.

## Purpose

OpenWRT's stock firewall configuration carries rules for use cases this router doesn't have.
Service-specific openings live with the role that needs them; this role removes the generic ones nothing depends on.

## Rationale

**Discovered on the router, not listed by name**, since stock rules may be renamed between releases.

**Consequence:** an internet-to-LAN opening can't be a plain rule targeting the LAN zone, because this role would delete it on every run.
Such openings are scoped to a single host instead.
