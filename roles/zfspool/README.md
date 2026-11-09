# zfspool

Imports each host's ZFS pool and configures snapshots, replication, scrubs and mounts.

## Purpose

The pools hold the data that recovery depends on, so the role stays out of the way of restoring it.

## Design

**No encryption.** Pools are deliberately unencrypted so a recovery never needs a disk key: the surviving disks can be imported on any machine.
Dataset properties that replication doesn't carry over are set here, so a rebuilt pool needs only to be created and then configured by a playbook run.

**Pool named after the host.** The pool takes the host's configured hostname, which can differ from its inventory name, and replication and recovery refer to pools by that name.
