# Roles
## zfspol
Configures ZFS backup and snapshot management, including setting up the syncoid user, delegating ZFS permissions, and managing automated snapshots via Sanoid and Syncoid.

## common
Installs and configures the Fish shell with shell environment configuration for the root user.

## container
Sets up container infrastructure including Podman and Buildah installation, systemd units for automated image building and pruning, and firewall rules.

## home
Configures Home Assistant integration by setting up firewall rules for HomeKit and mDNS services, and installing udev rules for ConBee device access.

## lid_switch
Configures system behavior when the laptop lid is closed by disabling the default suspend action via systemd logind settings.
