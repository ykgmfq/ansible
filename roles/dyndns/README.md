# dyndns

Makes the host reachable over IPv6 and keeps its public DNS record current.

## Purpose

The host sits behind a dual-stack router.
The router keeps the IPv4 `A` record up to date through its own built-in DynDNS client.
IPv6 has no NAT, so the `AAAA` record must point at the host itself rather than the router — and the router cannot publish an internal host's address into a third-party record.
This role gives the host everything it needs to own that side of its own reachability.

## Rationale

**EUI-64 addressing.** The router's inbound IPv6 port shares are pinned to the host's EUI-64 interface suffix.
NetworkManager otherwise defaults to a stable-privacy address, which is not the address the router opened and which rotates whenever the ISP prefix changes.
The role sets EUI-64 as the connection default so the global address stays constant and matches the opened ports.
Applying it requires reactivating the connection or rebooting, so the change only emits a reminder rather than bouncing the link mid-run.

**IPv6 ingress.** The reverse-proxy container is published on both IPv4 and IPv6 (`PublishPort=[::]:80:80` / `[::]:443:443`).
Netavark only creates IPv6 DNAT rules when the container has an IPv6 address, so the container is attached to a dedicated `ingress.network` with `IPv6=true`.
That network assigns the container a ULA IPv6 address and netavark installs the corresponding `dnat ip6 to [...]` rules, making both stacks reach Caddy directly without an intermediary proxy.

**DynDNS updater.** A oneshot service reads the host's stable global address and publishes it as the `AAAA` record, driven by a timer that fires every few minutes but only contacts the provider when the address actually changed, to stay within DynDNS fair-use.
The provider password is provisioned out of band and exposed to the service through systemd `LoadCredential`, so it never enters the environment or the process arguments; this role does not manage the secret.
