# Roles

Each role's README holds its purpose and rationale; `roles/CLAUDE.md` holds the conventions.

- **hostname**: hostname on every headless host.
- **fcos_base**: base configuration for Fedora CoreOS hosts.
- **zfspool**: ZFS pool management, snapshots and replication.
- **lid_switch**: ignore lid-close on a headless laptop-chassis server.
- **container**: Podman/Buildah infrastructure and helper units.
- **home**: Home Assistant integration prerequisites.
- **systempub**: publishes ZFS and systemd state to the MQTT broker.
- **ssh_keys**: extra root SSH keys on every host, from the personal repo.
- **dyndns**: IPv6 reachability for the host.
- **router_login**, **router_wan**, **router_firewall**, **router_lan**, **router_led**, **router_ddns**: OpenWRT router base configuration.
- **wireguard**: road-warrior endpoint on the router.
- **wireguard_client**: tunnel client on the backup host.
- **homeserver_passthrough**: inbound web and SSH to the homeserver through the router.
- **https_dns_proxy**: encrypted DNS for the router.
