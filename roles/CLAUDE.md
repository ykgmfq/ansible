# CLAUDE.md — Roles

Agent guidance for working within this directory. See the [top-level CLAUDE.md](../CLAUDE.md) for project-wide conventions and commands.

## Conventions

- Run `just lint` after any change to tasks, handlers, templates, or vars, and fix all reported issues before finishing.
- File modes must use symbolic `ugo=` notation — never octal.
- Role tasks should be small and focused; split into sub-task files when a role grows.
- Both plays connect as `remote_user: root` with `become: false` — no privilege escalation needed.
- Galaxy collections must be installed before running the playbook (`just galaxy`).

## Safety

- Do not run `just playbook` without explicit user confirmation — the target is a production host.
- Use `just playbook-check` for dry-runs.
- The `container` role expects `/var/mnt/persist/` and `/var/mnt/ephemeral/` to be mounted ZFS datasets — these will not exist in a test environment.
- **Never write systemd units directly to `/etc/systemd/system/`** — `/etc` is managed by confext in this setup. Unit files must go into the appropriate confext tree under `extensions/` and be deployed via `systemd-confext`.
- **Never use `enabled: true` in `systemd_service` tasks** — units and timers are enabled by placing `.wants` symlinks in the confext staging directory on the host. Create these server-side in `stage-host-config.yml` using `ansible.builtin.file` with `state: link`, after the sync task (so `delete: true` does not remove them).
- When editing Quadlet or systemd unit files, validate with `podman-system-generator -dryrun` or `systemd-analyze verify` if possible.
