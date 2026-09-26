# wireguard

Road-warrior WireGuard endpoint on the router, including the firewall rule it needs to actually receive traffic.

## Purpose

Lets road-warrior clients (phone, laptop) tunnel into the home network from anywhere. Owns everything the tunnel needs end-to-end — the interface, its peers, and the inbound firewall opening — rather than splitting the feature across roles.

## Rationale

**Private key generated in-role, not vaulted.** The router's own WireGuard private key is generated once with `wg genkey` on first run (only when `uci get network.wg0.private_key` fails) and never leaves the device — it lives only in `/etc/config/network` on the router, so there's no secret to manage or rotate in this repo. Only peers' *public* keys (non-secret) are tracked here, via the `wireguard_peers` list.

**Minimal firewall footprint.** The `wg` zone forwards to `lan` and the router accepts the tunnel's own traffic, but nothing is masqueraded — IPv4 clients reach the LAN directly through the tunnel's private subnet, no NAT layered on top.
