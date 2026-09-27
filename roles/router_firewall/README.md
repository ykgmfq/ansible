# router_firewall

Removes blanket `wan`→`lan` forwarding rules from the router's UCI firewall config.

## Purpose

OpenWRT's stock `firewall` config carries rules for use cases this router doesn't have. Service-specific openings live with the role that needs them (e.g. `roles/wireguard`, `roles/homeserver_passthrough`); this role removes the generic ones nothing here depends on.

## Rationale

**Discovered on the router, not listed by name.** Rather than naming stock rules that may or may not exist (or be renamed between OpenWRT releases), the role finds every UCI `rule` matching `router_firewall_absent_rules_match` (default: `src wan`, `dest lan`) and deletes it.

**Consequence:** a `wan`→`lan` opening can't be a UCI rule with `dest lan` — this role would delete it on every run. Scope such openings to a host the way `roles/homeserver_passthrough` does.

**Deleted back to front.** UCI addresses anonymous rules by index (`@rule[N]`), and deleting one renumbers all later ones, so matches are removed highest index first.
