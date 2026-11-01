# wireguard_client

Keeps a headless host connected to the router's WireGuard endpoint, so it stays reachable over SSH while offsite.

## Purpose

The backup host travels away from the home network. As a tunnel client it dials home, and from the tunnel's address space it is reachable like any other road-warrior device.

## Rationale

**Dials out, never listens.** The host is typically behind someone else's NAT, so it initiates the tunnel and keeps it alive with a persistent keepalive; nothing needs opening on its side.

**Tunnel subnet only.** `wireguard_client_allowed_ips` defaults to the tunnel subnet, so the host's normal traffic is not routed home while offsite.

**Enrolled like any other client.** The host's public key and tunnel IP are registered as a peer on the router the same way a phone's are (see `roles/wireguard`); this role only needs its own private key, address, and the endpoint's public key and host, all supplied from outside.

**Managed by NetworkManager.** The tunnel is a NetworkManager connection profile (WireGuard is built into the kernel and NetworkManager on Fedora CoreOS), so nothing needs layering and it autoconnects at boot. The profile is a keyfile edited in place with `ini_file`, which keeps the run idempotent and the key out of command lines.
