# Server deployment with Ansible
## 1. Prepare the Butane Configuration

First, generate the Butane configuration file, which is a human-friendly format for describing Fedora CoreOS system configuration. See the [Butane documentation](https://coreos.github.io/butane/) for more details.

```sh
just butane
```

### 2. Install Fedora CoreOS
Next, start an HTTP server to serve the Ignition file. This command displays your network interface IP addresses and then serves the `server.ign` file via HTTP on port 9001:

```sh
just ignition
```

Use the CoreOS installer to write the system to disk. This command installs Fedora CoreOS to the specified device and applies the Ignition configuration from the HTTP server. Replace the IP address with the one shown by the previous command, and replace `/dev/nvme0n1` with your actual target disk if needed.

For more information, refer to the [Fedora CoreOS bare-metal installation documentation](https://docs.fedoraproject.org/en-US/fedora-coreos/bare-metal/).

```sh
sudo coreos-installer install /dev/nvme0n1 --insecure-ignition --ignition-url http://192.168.0.99:9001/server.ign
```

### 3. Run Ansible Playbook

Put the master password in `pw.txt`.
Once the host is running, execute the Ansible playbook to complete the configuration and deploy application services:

```sh
just playbook
```
