# wireguard_client

Keeps a headless host connected to the router's WireGuard endpoint, so it stays reachable over SSH while offsite.

## Rationale

**Dials out, never listens.** The host is typically behind someone else's NAT, so it initiates the tunnel and keeps it alive; nothing needs opening on its side.

**Tunnel subnet only by default**, so the host's normal traffic is not routed home while offsite.

**Enrolled like any other client.** Its public key and tunnel address are registered as a peer on the router the same way a phone's are.

**Managed by the network manager.** The tunnel autoconnects at boot and needs no layered packages.
The profile is edited in place, which keeps the key out of command lines.

**Enrolled onsite.** The tunnel is the only way in once the host is offsite, so it is set up and checked while the host is still on the LAN.
