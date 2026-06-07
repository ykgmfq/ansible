# Server deployment with Ansible

Configures a Fedora CoreOS homeserver using Ansible and Butane/Ignition.

## Workflow

1. **Provision** — run `just ignition` to build the Ignition file and serve it, then install CoreOS on the target machine
2. **Configure** — run the Ansible playbook against the running host (`just playbook`)

See the [Butane docs](https://coreos.github.io/butane/) and [Fedora CoreOS bare-metal installation docs](https://docs.fedoraproject.org/en-US/fedora-coreos/bare-metal/) for details on initial provisioning.

## Common commands

Run `just -l` to list all available commands.
