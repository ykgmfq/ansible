# dns_over_tls

Strict DNS-over-TLS for the router's own resolution, with no plaintext fallback.

## Purpose

All of the router's own DNS queries go out encrypted over IPv6. Kept generic (not router-specific in name or content) so it can be reused on any future OpenWRT device.

## Rationale

**stubby, not dnsmasq, does the encryption.** dnsmasq has no DNS-over-TLS support of its own, so `stubby` (a dedicated DoT stub resolver) sits in front of it as the only upstream: `dhcp.@dnsmasq[0].noresolv=1` stops dnsmasq from ever falling back to DHCP-provided or `/etc/resolv.conf` resolvers, and its sole `server` is stubby's loopback listener (`127.0.0.1#5453`).

**Strict, not opportunistic.** `tls_authentication '1'` (stubby's default, set explicitly here) means a resolver's certificate must validate or the query fails outright — never a silent downgrade. `dns_transport` is pinned to `GETDNS_TRANSPORT_TLS` only, so there's no TCP/UDP fallback transport for stubby to fall back to either.
