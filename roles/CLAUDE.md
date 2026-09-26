# CLAUDE.md — Roles

Agent guidance for working within this directory. See the [top-level CLAUDE.md](../CLAUDE.md) for project-wide conventions and commands.

## Conventions

- Run `just lint` after any change to tasks, handlers, templates, or vars, and fix all reported issues before finishing.
- File modes must use symbolic `ugo=` notation — never octal.
- Role tasks should be small and focused; split into sub-task files when a role grows.
- The `router` play targets OpenWRT and uses `community.openwrt.*` modules (shell-based, no Python needed on the target) instead of the usual `ansible.builtin`/`community.general` ones; it also runs with `gather_facts: false` since the default `setup` module needs Python.
- Galaxy collections must be installed before running the playbook (`just galaxy`).

## Safety

- Do not run `just playbook` without explicit user confirmation — the target is a production host.
- Use `just playbook-check` for dry-runs.
- The `container` role expects `/var/mnt/persist/` and `/var/mnt/ephemeral/` to be mounted ZFS datasets — these will not exist in a test environment.
- When editing Quadlet or systemd unit files, validate with `podman-system-generator -dryrun` or `systemd-analyze verify` if possible.
