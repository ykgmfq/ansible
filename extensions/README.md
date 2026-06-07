# Extensions

Sysext and confext trees deployed by the `extensions` Ansible role.

## prod-units (sysext)
Systemd units and helper scripts for container image building, pruning, and service slices.

## home-automation (confext)
Firewall service and zone for HomeKit, and a udev rule for the ConBee Zigbee adapter.

## host-config (confext)
Host-specific configuration: Fish shell, rpm-ostree policy, logind, sanoid snapshots, and masked units. The `sanoid.conf` is rendered from a template at deploy time.
