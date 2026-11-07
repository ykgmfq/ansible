# https_dns_proxy

Encrypted DNS-over-HTTPS for the router's own resolution, with no plaintext fallback, via a personal AdGuard DNS endpoint.

## Purpose

Kept generic so it can be reused on any OpenWRT device.

## Rationale

**A separate proxy does the encryption.** The local resolver has no DoH support of its own; local proxy instances are its only upstreams, and it is stopped from falling back to DHCP-provided or system resolvers.

**Upstreams are managed here, not by the package.** The proxy's own resolver auto-configuration is disabled so this role stays the single source of truth, and the packaged default instances are removed.
Changes made in the web UI are overwritten on the next run.

**IPv6 only**, for both bootstrap and DoH traffic.

**Bootstrap by IP.** The proxy resolves the resolver's hostname once via fixed Quad9 addresses, so it doesn't depend on the router's own resolver.
That one lookup is plain DNS; everything after it goes over DoH.

**Clock sync by IP.** DoH certificate validation needs a correct clock.
NTP hostnames are therefore resolved on the Ansible host and written to the router as IPs, since resolving them on the router would need the very DNS that is broken.

**Quad9 as ordered backup.** An unfiltered Quad9 instance follows the personal endpoint and is used only when the first fails.
