# Homeserver and router deployment with Ansible

Configures a Fedora CoreOS homeserver and an OpenWRT router using Ansible and Butane/Ignition.

## Workflow

**Homeserver:**

1. **Provision** — run `just ignition` to build the Ignition file and serve it, then install CoreOS on the target machine
2. **Configure** — run `just playbook servers` against the running host

See the [Butane docs](https://coreos.github.io/butane/) and [Fedora CoreOS bare-metal installation docs](https://docs.fedoraproject.org/en-US/fedora-coreos/bare-metal/) for details on initial provisioning.

**Router:**

Configure the OpenWRT router with Ansible.

1. **Provision SSH access** — in the router's web interface (LuCI, *System → Administration → SSH-Keys*), add your public SSH key for `root`
2. **Trust the host key** — connect once with `ssh root@<router address>` and accept the router's host key fingerprint, so Ansible can connect with host key checking enabled
3. **Prep** — when migrating from an existing active router, run `just playbook router_prep`: it targets the new router while it's still reachable at its factory-default address, so WAN/WireGuard/etc. can be verified before it goes live
4. **Go live** — run `just playbook network`: its first run switches the router onto the production LAN subnet/DHCP and hands DNS ownership over from the old router, and every run after that is routine idempotent maintenance of the whole stack

Router secrets (WireGuard key, DynDNS password) and the list of WireGuard client devices are read from Vaultwarden through [rbw](https://github.com/doy/rbw), which the router recipes unlock before each run. Configure it once per container with `rbw config set email <address>` and `rbw config set base_url <vaultwarden url>`. The homeserver's secrets live on its own ZFS pool instead, so provisioning it never depends on Vaultwarden.

The host key is recorded per address, so after the go-live cutover moves the router to its production address, repeat step 2 against that address before the next run.

## Common commands

Run `just -l` to list all available commands.

## Devcontainer

*Reopen in Container* offers two configurations:

- **local build** — builds the image from `.devcontainer/Dockerfile` on your machine
- **prebuilt** — pulls `ghcr.io/ykgmfq/ansible`
