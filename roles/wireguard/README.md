# wireguard

Road-warrior WireGuard endpoint on the router, including the firewall rule it needs to actually receive traffic.

## Purpose

Lets road-warrior clients (phone, laptop) tunnel into the home network from anywhere. Owns everything the tunnel needs end-to-end — the interface, its peers, and the inbound firewall opening — rather than splitting the feature across roles.

## Rationale

**Private key supplied, not generated.** The router's own private key (`wireguard_private_key`, required) comes from outside the role, so a replacement router takes over the same identity and peers keep working without re-enrollment. Only peers' *public* keys (non-secret) are tracked here, via the `wireguard_peers` list.

**Narrow NAT.** The `wg` zone forwards to `lan` and the router accepts the tunnel's own traffic. Only tunnel-sourced traffic leaving via `lan` is masqueraded: some LAN devices (e.g. FRITZ!Box) refuse logins from addresses outside their own subnet, and masquerading also removes the need for return routes on them.
