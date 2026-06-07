# Roles

## common
Base configuration for all headless hosts: Fish shell, system services, and automatic OS upgrades.

## zfspool
ZFS pool management: user setup, pool import, permissions, scrub/snapshot timers, and (on backup sinks) replication via Syncoid.

## extensions
Deploys sysext and confext trees to the host and activates them via `systemd-sysext` and `systemd-confext`.

## container
Container infrastructure: Buildah, Podman secrets, Quadlet service sync, auto-update timer, and firewall rules.

## home
Restarts firewalld to apply confext-provided firewall zones and services.
