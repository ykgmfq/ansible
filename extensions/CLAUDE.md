# CLAUDE.md — Extensions

Agent guidance for working within this directory. See the [top-level CLAUDE.md](../CLAUDE.md) for project-wide conventions.

## Structure

Each subdirectory is a sysext or confext tree that mirrors the target filesystem layout. Files are synced to the host by the `extensions` Ansible role and activated via `systemd-sysext` / `systemd-confext`.

## Editing

- Changes here take effect on the next playbook run — no rebuild step required.
- `host-config/etc/sanoid/sanoid.conf` is overwritten at deploy time by the Ansible template; edit the template at `roles/extensions/templates/host-config/etc/sanoid/sanoid.conf.j2` instead.
- After any change, run `just lint` to catch Ansible issues in the role that deploys these trees.
