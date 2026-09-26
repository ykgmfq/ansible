# https_passthrough

The one firewall rule that lets inbound TLS (and ACME's plain HTTP) reach the homeserver directly.

## Purpose

The homeserver terminates its own TLS (Caddy, per `roles/dyndns/README.md`) and is directly reachable over IPv6 — there's no NAT to configure, only a `wan`→`lan` forwarding opening for ports 80/443. Kept as its own role since it's a distinct concern (ingress for a *different* host) from the router's own VPN/DNS.

## Rationale

**No `dest_ip`, no destination-MAC match — matched on the homeserver's stable interface identifier instead.** A plain `dest_ip` firewall rule would silently stop working the moment the ISP redelegates a new prefix, since only the homeserver's GUA *host part* is stable (via EUI-64, see `roles/dyndns`) — the *prefix* is whatever's currently routed. Destination-MAC matching looks like the obvious fix ("bind to the device, not the address") but doesn't actually work: by the time a packet reaches netfilter's `forward` hook, the outbound Ethernet header hasn't been finalized by neighbour resolution yet, so `ether daddr` matches on forwarded traffic are unreliable — a Linux netfilter limitation, not an OpenWRT one.

Instead, this role installs a small nftables snippet (`/etc/https-passthrough.nft`, included by a UCI `firewall.include` section at the start of fw4's `forward_wan` chain) that matches on the destination address **masked down to its lower 64 bits** — the homeserver's EUI-64 interface identifier — regardless of which prefix is currently routed there. UCI's `firewall.rule` schema has no masked/suffix match, hence the raw nftables snippet instead of a UCI section. It must not go in `/etc/nftables.d/`: fw4 includes that directory at table level, where a bare rule is a syntax error that stops the entire firewall (including NAT) from loading.

`https_passthrough_homeserver_ipv6_iid` (`group_vars/router/main.yml` — it identifies this specific deployment's homeserver, not a generic role default) is the homeserver's current interface identifier, read directly off the box with `ip -6 addr show scope global`. It only needs updating here if the homeserver's NIC (and therefore its MAC-derived EUI-64 suffix) ever changes.
