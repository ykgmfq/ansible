# CLAUDE.md — AI Agent Guide

## Project overview

This repository configures a Fedora CoreOS (uCore HCI) homeserver using Ansible and Butane/Ignition. The workflow is:

1. **Butane** (`server.butane`) → generate `server.ign` (Ignition) for initial OS provisioning
2. **Ansible** (`production.yml`) → configure the running host and deploy container services

The target host is `dm-poepperl.de` (group `homeserver`, child of `headless`). A `backup` group exists but is currently commented out in `inventory.yml`.

## Repository layout

```
ansible.cfg          # Ansible config (YAML output, pipelining enabled)
inventory.yml        # Hosts: headless > homeserver (dm-poepperl.de) + backup
production.yml       # Main playbook (common → zfspool → extensions → container → home)
server.butane        # Butane source for Ignition; compile with `just butane`
justfile             # Task runner shortcuts (see below)
extensions/          # Sysext/confext trees synced by the extensions role
  prod-units/        # Systemd sysext
  home-automation/   # Confext: HomeKit firewalld service, ConBee udev rule, firewall zones
  host-config/       # Confext: fish config, rpm-ostree policy, logind, sanoid
roles/
  common/            # Fish shell (via rpm-ostree), tuned/oomd services, auto-upgrades
  zfspool/           # ZFS pool import, sanoid snapshots, syncoid replication
  extensions/        # Sysext/confext sync, staging, and activation
  container/         # Podman/Buildah, Quadlet unit files, firewall
  home/              # Firewalld restart
  requirements.yml   # Galaxy collections: community.general, ansible.posix, containers.podman, community.crypto
```

## Common commands

```sh
just butane            # Compile server.butane → server.ign
just lint              # Run ansible-lint (does not compile Butane)
just playbook          # Run ansible-playbook (with diff)
just playbook-check    # Dry-run (--check --diff)
just playbook-verbose  # Run with -vvv
just galaxy            # Install Galaxy collections from roles/requirements.yml
just ignition          # Show IPs and serve server.ign on :9001 for bare-metal install
```

## Roles

### common
- Installs `fish` via `rpm-ostree`
- Enables `tuned` and `systemd-oomd`
- Enables `rpm-ostreed-automatic.timer` (policy and schedule are in the `host-config` confext)

### zfspool
- Creates `syncoid` system user
- Imports ZFS pool (`data` on homeserver, `backup` on backup sink)
- Applies `zfs_delegate_admin` permissions for syncoid
- Enables `zfs-scrub-monthly` and `sanoid` timers
- On backup sink only: deploys `syncoid@.timer/service` for `persist` and `media` datasets

### extensions
- Ensures `/var/lib/extensions/` and `/var/lib/confexts/` directories exist
- Syncs `extensions/prod-units/` → `/var/lib/extensions/prod-units/` (sysext)
- Syncs `extensions/home-automation/` → `/var/lib/confexts/home-automation/` (confext)
- Stages `host-config` confext: syncs base tree then renders `roles/extensions/templates/host-config/etc/sanoid/sanoid.conf.j2` with host-specific vars (`dataset`, `is_backup_sink`) into `/var/lib/confexts/host-config/`
- Enables and starts `systemd-sysext` and `systemd-confext` services
- Runs `systemd-sysext refresh`, `systemd-confext refresh`, and reloads the systemd daemon

### container
- Installs `buildah` via `rpm-ostree`
- Runs `/var/mnt/persist/podman-secrets/register.fish` to load container secrets into Podman
- Runs `fish sync.fish` in `/var/mnt/ephemeral/services` to sync Quadlet service definitions
- Enables `podman-auto-update.timer`
- Opens firewall: http, https, http3, samba

### home
- Restarts firewalld (HomeKit service, ConBee udev rule, and firewall zones are in the `home-automation` confext)

## Conventions

- **File modes** always use symbolic `ugo=` notation — never octal. Examples: `mode: "ugo=r"`, `mode: "u=rwx,go=rx"`, `mode: "u=rw,go="`. Executables: `mode: "ugo=rx,u+w"`.
- **After any change** to an Ansible file (tasks, handlers, playbooks, vars, templates), run `just lint` and fix all reported issues before finishing.
- **Always use `just` commands** instead of invoking tools directly — `just butane` not `butane …`, `just playbook-check` not `ansible-playbook … --check`, etc. This keeps invocations within the project allowlist.

## Notes for agents

- **Do not run `just playbook`** against the live host without explicit user confirmation — the host is a production homeserver.
- **`just playbook-check`** is safe for dry-runs.
- **`just lint`** runs `ansible-lint` across the whole project.
- Both plays in `production.yml` connect as `remote_user: root` with `become: false` — no privilege escalation needed.
- When editing Quadlet or systemd unit files, validate syntax with `podman-system-generator -dryrun` or `systemd-analyze verify` if possible.
- The `server.butane` file controls initial OS provisioning; changes there only take effect on a fresh install. For running-host changes, use Ansible roles.
- Galaxy collections must be installed before running the playbook (`just galaxy`).
- The `container` role expects `/var/mnt/persist/` and `/var/mnt/ephemeral/` to be mounted ZFS datasets on the target host — they will not exist in a test environment.
