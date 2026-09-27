# Roles

## common
Base configuration for all headless hosts: Fish shell, system services, and automatic OS upgrades.

## zfspool
ZFS pool management: user setup, pool import, permissions, scrub/snapshot timers, and (on backup sinks) replication via Syncoid.

## lid_switch
Disables the default lid-close suspend action via systemd logind settings — headless server in a laptop chassis.

## container
Container infrastructure: Buildah, Podman secrets, systemd units for image building and pruning, Quadlet service sync, auto-update timer, firewall rules, and helper scripts.

## home
Home Assistant integration: firewall rules for HomeKit and mDNS services, udev rule for ConBee device access.

## dyndns
IPv6 reachability for the host.

## router_wan
IPv4/IPv6 WAN connectivity for the OpenWRT router, carried over from the router it replaces.

## router_firewall
Removes blanket wan→lan forwarding rules, such as OpenWRT's stock IPsec passthrough, found on the router itself.

## router_lan
Switches the OpenWRT router's LAN from its factory default onto the subnet owned by the router it replaces, DHCP pool included — the go-live step, run as part of `playbooks/network.yml`'s full stack.

## wireguard
Road-warrior WireGuard endpoint on the router, including the firewall rule it needs to receive traffic.

## router_ddns
Keeps the router's own public DNS record pointed at its current IPv6 address.

## homeserver_passthrough
Firewall rules letting inbound web and SSH traffic reach the homeserver directly through the router.

## dns_over_tls
Strict DNS-over-TLS for the router's own resolution, with no plaintext fallback.
