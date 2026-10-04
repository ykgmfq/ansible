# https_dns_proxy

Encrypted DNS-over-HTTPS for the router's own resolution, with no plaintext fallback, via a personal AdGuard DNS endpoint.

## Purpose

All of the router's own DNS queries go out encrypted. Kept generic (not router-specific in name or content) so it can be reused on any future OpenWRT device.

## Rationale

**https-dns-proxy, not dnsmasq, does the encryption.** dnsmasq has no DoH support of its own, so local `https-dns-proxy` instances sit in front of it as the only upstreams: `dhcp.@dnsmasq[0].noresolv=1` stops dnsmasq from falling back to DHCP-provided or `/etc/resolv.conf` resolvers, and its `server` list holds just the proxies' loopback listeners.

**Upstreams are managed here, not by the package.** Redirecting LAN clients' own DNS to the router (`force_dns`) is off. The proxy's own dnsmasq auto-configuration is disabled so this role stays the single source of truth, and the packaged default instances are removed. The LuCI app is installed for inspection; changes made there are overwritten on the next run.

**IPv6 only.** The proxy is forced to IPv6 (`force_ip_family`), for both bootstrap and DoH traffic.

**Bootstrap by IP.** The proxy resolves the resolver's hostname once via fixed Quad9 IPv6 addresses, so there is no dependency on any plaintext resolver.
