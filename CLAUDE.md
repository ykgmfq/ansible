# CLAUDE.md — AI Agent Guide

## Project overview

This repository configures a Fedora CoreOS (uCore HCI) homeserver and an OpenWRT router using Ansible and Butane/Ignition. The workflow is:

1. **Butane** (`server.butane`) → generate `server.ign` (Ignition) for initial OS provisioning of the homeserver
2. **Ansible** (`playbooks/servers.yml`, `playbooks/network.yml`) → configure the running hosts and deploy services

`playbooks/servers.yml` covers the FCoS side: the target host is in group `homeserver` (child of `headless`). A `backup` group exists but is currently commented out in the personal inventory. `playbooks/network.yml` covers the OpenWRT router (group `router`).

The router has two playbooks: `playbooks/router_prep.yml` runs against a new/replacement router still at OpenWRT's factory-default address, verifying WAN/WireGuard/etc. before it goes live. `playbooks/network.yml` is the full-stack idempotent playbook — its first run against a freshly-prepped device performs the go-live cutover (switching the LAN/DHCP subnet and starting DNS for the domain the previously-active router owned), and every run after that is routine maintenance of the whole stack.

## Repository layout

```
ansible.cfg                  # Ansible config
personal/                    # Personal repo (git submodule): inventory, group_vars, device-specific values
playbooks/servers.yml        # FCoS homeserver/backup playbook
playbooks/router_prep.yml    # New/replacement router prep (factory-default address)
playbooks/network.yml        # Full-stack idempotent OpenWRT router playbook
server.butane                # Butane source for Ignition; compile with `just butane`
justfile                     # Task runner shortcuts
roles/                       # Ansible roles — see roles/CLAUDE.md
```

## Common commands

Run `just -l` to list all available commands. Playbook recipes take the playbook name as an argument, e.g. `just playbook-check servers` or `just playbook network`.

## Conventions

- **Device-specific values go in the personal repo at `personal/`**, not here — hostnames, domains, addresses, MACs, leases, the adblock endpoint. Roles keep generic defaults; see `personal/README.md` for the variables expected.
- **Always use `just` commands** instead of invoking tools directly.
- **Keep CLAUDE.md and README files general** — describe purpose and scope, not implementation details.
- **Comment only what is truly non-obvious** — keep comments short and don't restate values, paths, or names defined elsewhere, since those drift.
- **Do not run `just playbook servers`, `just playbook network`, or `just playbook router_prep`** without explicit user confirmation — all three target production hosts, and `network`'s first run against a new device additionally switches the live subnet and DNS ownership.
- **`server.butane`** only takes effect on a fresh install; use Ansible roles for changes to a running host.
