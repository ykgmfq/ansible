# CLAUDE.md — AI Agent Guide

## Project overview

This repository configures a Fedora CoreOS (uCore HCI) homeserver using Ansible and Butane/Ignition. The workflow is:

1. **Butane** (`server.butane`) → generate `server.ign` (Ignition) for initial OS provisioning
2. **Ansible** (`production.yml`) → configure the running host and deploy container services

The target host is `dm-poepperl.de` (group `homeserver`, child of `headless`). A `backup` group exists but is currently commented out in `inventory.yml`.

## Repository layout

```
ansible.cfg          # Ansible config
inventory.yml        # Host inventory
production.yml       # Main playbook
server.butane        # Butane source for Ignition; compile with `just butane`
justfile             # Task runner shortcuts
roles/               # Ansible roles — see roles/CLAUDE.md
```

## Common commands

Run `just -l` to list all available commands.

## Conventions

- **Always use `just` commands** instead of invoking tools directly.
- **Keep CLAUDE.md and README files general** — describe purpose and scope, not implementation details.
- **Do not run `just playbook`** without explicit user confirmation — the target is a production host.
- **`server.butane`** only takes effect on a fresh install; use Ansible roles for changes to a running host.
