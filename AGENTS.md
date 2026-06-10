# AGENTS.md — AI Agent Guide

## Project overview

This repository configures a Fedora CoreOS (uCore HCI) homeserver using Ansible and Butane/Ignition. The workflow is:

1. **Butane** (`server.butane`) → generate `server.ign` (Ignition) for initial OS provisioning
2. **Ansible** (`production.yml`) → configure the running host and deploy container services

The target host is `dm-poepperl.de` (group `homeserver`, child of `headless`). A `backup` group exists but is currently commented out in `inventory.yml`.

## Repository layout

```
ansible.cfg          # Ansible config (YAML output, vault password from pw.txt)
inventory.yml        # Hosts: headless > homeserver (dm-poepperl.de) + backup
production.yml       # Main playbook (common → zfspool → lid_switch → container → home)
server.butane        # Butane source for Ignition; compile with `just butane`
secrets.yml          # Ansible Vault–encrypted variables
pw.txt               # Vault password file (not committed, must exist locally)
justfile             # Task runner shortcuts (see below)
roles/
  common/            # Fish shell, tuned/oomd services, rpm-ostree auto-upgrades
  zfspool/           # ZFS pool import, sanoid snapshots, syncoid replication
  lid_switch/        # logind: ignore lid close
  container/         # Podman/Buildah, Quadlet unit files, firewall, scripts
  home/              # HomeKit firewalld service, ConBee USB udev rule
  requirements.yml   # Galaxy collections: community.general, ansible.posix, containers.podman, community.crypto
```

## Common commands

```sh
just butane            # Compile server.butane → server.ign
just playbook          # Run ansible-playbook (with diff)
just playbook-check    # Dry-run (--check --diff)
just playbook-verbose  # Run with -vvv
just galaxy            # Install Galaxy collections from roles/requirements.yml
just ignition          # Show IPs and serve server.ign on :9001 for bare-metal install
```

## Roles

### common
- Installs `fish` via `rpm-ostree`
- Drops `/root/.config/fish/config.fish`
- Enables `tuned` and `systemd-oomd`
- Configures `rpm-ostreed` for automatic OS upgrades on a Saturday timer

### zfspool
- Creates `syncoid` system user
- Imports ZFS pool (`data` on homeserver, `backup` on backup sink)
- Applies `zfs_delegate_admin` permissions for syncoid
- Enables `zfs-scrub-monthly` and `sanoid` timers
- On backup sink only: deploys `syncoid@.timer/service` for `persist` and `media` datasets

### lid_switch
- Sets `HandleLidSwitch=ignore` in logind (headless server with a laptop chassis)
- Notifies operator to reboot after change (handler emits a debug message)

### container
- Installs `buildah` via `rpm-ostree`
- Runs `/var/mnt/persist/podman-secrets/register.fish` to load container secrets
- Copies static systemd unit files from `roles/container/files/units/` → `/etc/systemd/system/`
- Syncs Quadlet service definitions from `/var/mnt/ephemeral/services/systemd` → `/etc/containers/systemd/` (delete-synced)
- Symlinks `prod.target` as the default systemd target
- Enables `podman-auto-update.timer`
- Validates Quadlet files with `podman-system-generator -dryrun` and asserts rc==0
- Opens firewall: http, https, http3, samba
- Copies scripts from `roles/container/files/scripts/` → `/usr/local/bin/`

### home
- Deploys HomeKit firewalld service XML
- Deploys ConBee USB stick udev rule
- Opens firewall: homekit, mdns

## Secrets

`secrets.yml` is Ansible Vault–encrypted. The vault password must be in `pw.txt` (path configured in `ansible.cfg`). Never commit `pw.txt`.

## Conventions

- **File modes** always use symbolic `ugo=` notation — never octal. Examples: `mode: "ugo=r"`, `mode: "u=rwx,go=rx"`, `mode: "u=rw,go="`. Executables: `mode: "ugo=rx,u+w"`.
- **After any change** to an Ansible file (tasks, handlers, playbooks, vars, templates), run `ansible-lint` and fix all reported issues before finishing.

## Notes for agents

- **Do not run `ansible-playbook` directly** against the live host without explicit user confirmation — the host is a production homeserver.
- **`just playbook-check`** is safe for dry-runs.
- When editing Quadlet or systemd unit files under `roles/container/files/units/`, validate syntax with `podman-system-generator -dryrun` or `systemd-analyze verify` if possible.
- The `server.butane` file controls initial OS provisioning; changes there only take effect on a fresh install. For running-host changes, use Ansible roles.
- Galaxy collections must be installed before running the playbook (`just galaxy`).
- The `container` role expects `/var/mnt/persist/` and `/var/mnt/ephemeral/` to be mounted ZFS datasets on the target host — they will not exist in a test environment.
