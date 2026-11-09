# dyndns

Makes the host reachable over IPv6 and keeps its public DNS record current.

## Purpose

The host is reachable from outside over IPv6 only; there is no IPv4 record.
No NAT is involved, so the address record must point at the host itself rather than the router, and the router cannot publish an internal host's address into a third-party record.

## Rationale

**Stable interface identifier.** The router's inbound IPv6 openings are pinned to the host's hardware-derived interface identifier.
The default privacy-oriented addressing would not match what the router opened and would rotate whenever the ISP prefix changes.
Applying the change needs a reconnect or reboot, so it only emits a reminder instead of interrupting the link mid-run.

**IPv6 ingress.** Container networking only creates IPv6 forwarding rules when the container has an IPv6 address, so the reverse proxy sits on a dedicated IPv6-enabled network.
Both address families then reach it directly without an intermediary proxy.

**Updater.** The provider is only contacted when the address actually changed, to stay within fair-use limits.
The provider password is provisioned out of band and handed to the service as a credential, so it never enters the environment or process arguments; this role does not manage the secret.
