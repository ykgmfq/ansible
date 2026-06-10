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
