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
- **Unit files go in confext/sysext, never written directly to `/etc/systemd/system/` by a role.** Config files and unit definitions belong in the appropriate `extensions/` tree, deployed via `systemd-sysext` / `systemd-confext`.
- **Enablement (`.wants` symlinks) must NOT live in confext** — confext and sysext merge late (at `sysinit.target`), *after* systemd has built the boot transaction, so any `.wants` symlink inside them is invisible at boot and the unit silently never starts (it only appears after a manual `daemon-reload`). Enablement must live in **base `/etc`** (the per-deployment writable layer, present before the merge), managed by `server.butane` for fresh installs. Do **not** use `enabled: true` in `systemd_service` tasks (it writes to `/etc`, which is read-only once confext is merged).
  - Units whose files are in base `/usr` (OS-provided: `tuned`, `systemd-oomd`, the system timers): enable with `storage.links` in `server.butane` pointing into `/etc/systemd/system/<target>.wants/`.
  - `prod.target` (sysext-provided) and its Quadlet services (confext-provided `.container` files): these are not loadable at boot-transaction time, so they are started by `prod-autostart.service` (in `server.butane`) — a base-`/etc` oneshot ordered `After=systemd-sysext.service systemd-confext.service` that runs `daemon-reload` (re-runs the Quadlet generator against the now-merged confext) then `systemctl start prod.target`.
  - Base `/etc` enablement is install-time state (set by Ignition, persists across reboots/ostree updates). The running host is brought into line with a one-time migration playbook (unmerge confext → write base `/etc` → merge); the regular roles do not manage enablement.
- When editing Quadlet or systemd unit files, validate with `podman-system-generator -dryrun` or `systemd-analyze verify` if possible.
