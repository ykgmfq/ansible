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

**IPv6 ingress bridge.** The reverse-proxy container runs under rootless Podman, which binds `[::]` but cannot forward inbound IPv6 into its IPv4-only container networks — connections are accepted and then hang.
The container therefore stays published on IPv4 only, and a templated systemd socket-proxy instance per port listens on `[::]:<port>` (IPv6-only, coexisting with the container's IPv4 listener) and forwards to loopback.
Because the proxy re-originates from loopback, the proxy sees the client as `127.0.0.1`; rootless ingress already does not preserve the real client IP, so this matches existing behaviour.

**DynDNS updater.** A oneshot service reads the host's stable global address and publishes it as the `AAAA` record, driven by a timer that fires every few minutes but only contacts the provider when the address actually changed, to stay within DynDNS fair-use.
The provider password is provisioned out of band and exposed to the service through systemd `LoadCredential`, so it never enters the environment or the process arguments; this role does not manage the secret.
