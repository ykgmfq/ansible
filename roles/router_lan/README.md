# router_lan

Switches the new OpenWRT router's LAN off its factory default and onto the subnet owned by the router it replaces, DHCP pool included.

## Purpose

Run `playbooks/router_prep.yml` first, against the router at OpenWRT's factory-default address, to confirm WAN (`roles/router_wan`), WireGuard, and the other non-LAN roles are working. Then point `playbooks/network.yml` at the device: this role switches its LAN address/netmask and DHCP pool to the production subnet as part of that same full-stack run, so the router starts serving the real network atomically rather than mid-way through unrelated config changes. On every run after that first one, this role is just idempotent upkeep of the same LAN config.

## Rationale

**LAN subnet, not the exact DHCP pool.** Only the subnet itself needs to match for existing devices to keep working. The dynamic pool uses OpenWRT's own standard default (`start 100`, `limit 150`) rather than chasing the active router's partially-implicit range.

**LAN IPv6 is SLAAC only.** The active router never ran a stateful DHCPv6 server on its LAN either (`dhcpv6lanmode_off` in its exported config); this role matches that by advertising RAs (`ra server`) but disabling DHCPv6 leasing (`dhcpv6 disabled`), and clearing OpenWRT's default M/O RA flags (`ra_flags none`) so clients aren't told to ask a DHCPv6 server that isn't there.

**First-contact IP changes.** Changing `network.lan.ipaddr` from OpenWRT's factory default (`192.168.1.1`) to `192.168.178.1` breaks the SSH connection Ansible used to make the change, since management traffic rides the LAN interface. Keep the inventory's `ansible_host` at `192.168.1.1` until this role has actually run, then update it to `192.168.178.1`.
