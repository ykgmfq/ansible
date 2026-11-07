# router_login

Controls how one logs in to the OpenWRT router: SSH is key-only, and the root password (for console and web UI) is set from a variable.

## Purpose

Ansible connects with an SSH key, so SSH password login is unnecessary.
The public key must already be authorized on the router before this role runs, or SSH access is lost.
