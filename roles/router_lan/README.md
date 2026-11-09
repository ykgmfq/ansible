# router_lan

Switches the new OpenWRT router's LAN off its factory default and onto the subnet owned by the router it replaces, DHCP pool included.

## Purpose

The router is first prepared at its factory-default address to confirm the non-LAN roles work.
The full-stack run then switches the LAN, so the router starts serving the real network atomically rather than mid-way through unrelated config changes.

## Rationale

**LAN subnet, not the exact DHCP pool.** Only the subnet needs to match for existing devices to keep working; the pool uses OpenWRT's standard default rather than chasing the old router's partially-implicit range.

**LAN IPv6 is SLAAC only.** The old router never ran a stateful DHCPv6 server either.
RAs are advertised, DHCPv6 leasing is disabled, and OpenWRT's default M/O RA flags are cleared so clients aren't told to ask a DHCPv6 server that isn't there.

**First-contact address change.** Changing the LAN address breaks the management connection, since management traffic rides the LAN interface.
The inventory must keep the factory default until the switch has happened.
