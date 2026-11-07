# CLAUDE.md — Roles

## Conventions

- Run `just lint` after any change to tasks, handlers, templates, or vars, and fix all reported issues before finishing.
- File modes must use symbolic `ugo=` notation — never octal.
- Role tasks should be small and focused; split into sub-task files when a role grows.
- The `router` play targets OpenWRT and uses `community.openwrt.*` modules (shell-based, no Python needed on the target) instead of the usual `ansible.builtin`/`community.general` ones; it also runs with `gather_facts: false` since the default `setup` module needs Python.
- Roles shared across host classes (e.g. `hostname`) dispatch with `include_tasks: "{{ platform }}.yml"`; `platform` (`fcos`, `openwrt`) is a group var in `playbooks/group_vars/`, since the router has no facts to branch on.
  Pool a capability into one role only when its variables and handlers are shared across platforms; platform-only capabilities stay separate roles.

## Safety

- The `container` role expects the ZFS datasets from `zfspool` to be mounted, which a test environment lacks.
- When editing Quadlet or systemd unit files, validate with `podman-system-generator -dryrun` or `systemd-analyze verify` if possible.
