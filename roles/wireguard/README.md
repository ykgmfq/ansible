# wireguard

Road-warrior WireGuard endpoint on the router, including the firewall rule it needs to receive traffic.

## Purpose

Owns everything the tunnel needs end-to-end (interface, peers, inbound firewall opening) rather than splitting the feature across roles.

## Rationale

**Private key supplied, not generated**, so a replacement router takes over the same identity and peers keep working without re-enrollment.
Only peers' public keys are tracked here.
If the key is lost, generate a new one and redistribute the public half to the clients.
Sync the password cache before changing peers, since the peer list is read from it.

**Narrow NAT.** Only tunnel-sourced traffic leaving into the LAN is masqueraded: some devices refuse logins from addresses outside their own subnet.

**LAN reaches peers.** LAN traffic into the tunnel is masqueraded as the router, because peers only route the tunnel subnet and could not answer LAN addresses.
