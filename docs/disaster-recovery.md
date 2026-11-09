# Disaster recovery

Something broke. Find it below and follow the link.

## What is broken?

| What happened | Do |
| --- | --- |
| My laptop or dev setup is gone, or the password cache is empty | [R0](disaster-recovery/r0-laptop.md) |
| Router misconfigured or has no DNS, but I can still SSH in | [R1a](disaster-recovery/r1-router.md) |
| Router dead, locked out or replaced | [R1b](disaster-recovery/r1-router.md) |
| One disk in a mirror failed | [R6](disaster-recovery/r6-mirror.md) |
| Homeserver OS broken, disks fine | [R2](disaster-recovery/r2-homeserver.md) (and [R6](disaster-recovery/r6-mirror.md) if a disk is bad) |
| Homeserver up, but services down | Run `just playbook servers`, then on the homeserver check `systemctl status prod.target` and the `image-build@` units |
| Files or a dataset deleted or damaged | [R3](disaster-recovery/r3-snapshots.md) |
| Both homeserver disks lost | [R4](disaster-recovery/r4-pool.md), then [R2](disaster-recovery/r2-homeserver.md) |
| Backup host dead, both USB disks lost, or backups keep failing | [R5](disaster-recovery/r5-backup.md) |
| The whole site is gone | [Full rebuild](#full-rebuild) |

## Your copies

| Copy | Where | Lost if you restore from it |
| --- | --- | --- |
| Snapshots | on the homeserver | up to one snapshot interval |
| Backup copy | USB disks at the backup site | everything since the last successful backup job |
| Password cache (`rbw`) | on the laptop | changes since the last `rbw sync` |
| Break-glass set | offline | changes since it was last updated |
| Services repo | GitHub | changes you never pushed |

- The backup job is the backup host's `syncoid@persist` and `syncoid@media` timers. It pulls from the homeserver.
- Only `persist` and `media` are copied. `ephemeral` is rebuilt from GitHub.
- Each pool is named after its host (the `hostname` value in the personal repo's `inventory.yml`). The procedures write `<homeserver pool>` and `<backup pool>`.
- Each pool is two disks that mirror each other. One failed disk loses no data (R6). Both failing loses the pool.
- If both pools are lost, the data is gone. There is no third copy.

## Break-glass set

It is kept offline, away from the USB disks. It has two things:

1. A hardware SSH key that works as root on every host. On a new laptop, run `ssh-keygen -K` to load it.
   The personal repo's README says which key it is.
2. The master password for the password manager (Vaultwarden).

Everything else can be rebuilt:
- The router root password is set again by `router_prep`.
- WireGuard keys, if lost with Vaultwarden, are regenerated and handed out again.
- The pools are not encrypted, so no disk key is needed.

## Rules

- **Treat the retrieved USB disks as the only copy.**
  Import them read-only (`readonly=on`, no mounts), copy from them, export them, put them back.
- **Name disks by ID.**
  Use `/dev/disk/by-id/…` paths and match the serial number to the drive in your hand before any command that writes.
- **Restore in this order:** router, `persist`, services, `media`, backups.
  `media` can wait.
- **Run the backup job soon after a restore**, before the homeserver deletes the snapshot both sides share.
  Otherwise the next backup is a full resend.
- **Commit service changes to the services repo.**
  Service definitions live in `ephemeral`, which is not backed up, so keep data in `persist`.
- **Reach hosts by IP address** (`ansible_host` in the personal repo's `inventory.yml`), so a stale DNS record can't block the fix.
  The one exception is the backup job, which reaches the homeserver by its public name.
- **Add `--skip-tags secrets` to router runs if there is no `rbw` cache and Vaultwarden is down.**
  Run them again without it once Vaultwarden is up.
  Homeserver secrets are on its own pool, so its runs never need this.
- **Run `rbw sync` before adding or removing WireGuard peers**, or an old peer list is pushed.
- **Set up a new backup host onsite**, on the LAN, after `router_prep`.

## Full rebuild

Each step needs the ones before it.

1. **Laptop:** follow [R0](disaster-recovery/r0-laptop.md).
2. **Router:** follow [R1b](disaster-recovery/r1-router.md). Without an `rbw` cache, skip secrets (see Rules); WireGuard, DoH and DynDNS stay off until step 5.
3. **Homeserver pool:** follow [R4](disaster-recovery/r4-pool.md).
4. **Homeserver:** follow [R2](disaster-recovery/r2-homeserver.md).
5. **Router secrets:** if step 2 skipped secrets, run `just playbook network` again without `--skip-tags`.
6. **Backup host:** follow [R5](disaster-recovery/r5-backup.md).

## Check it worked

After any procedure:

- `dig +short AAAA <public name>` returns the homeserver's address, and its HTTPS page and SSH work from a phone off Wi-Fi.
- A WireGuard client off Wi-Fi connects to the router and shows a recent handshake.
- `rbw sync` finishes without an error.
- On the backup host, `systemctl start syncoid@persist syncoid@media` finishes without an error.
- On the homeserver and the backup host, `zpool status -x` says all pools are healthy.

## Practice

Once a year: import the USB pool read-only on a spare machine and copy one dataset with `zfs send` to scratch storage.
That proves the disks, the pool and these steps still work.
