# wireguard

Road-warrior WireGuard endpoint on the router, including the firewall rule it needs to receive traffic.

## Purpose

Owns everything the tunnel needs end-to-end (interface, peers, inbound firewall opening) rather than splitting the feature across roles.

## Rationale

**Private key supplied, not generated**, so a replacement router takes over the same identity and peers keep working without re-enrollment.
Only peers' public keys are tracked here.

**Narrow NAT.** Only tunnel-sourced traffic leaving into the LAN is masqueraded: some LAN devices (e.g. FRITZ!Box) refuse logins from addresses outside their own subnet, and masquerading also removes the need for return routes on them.
