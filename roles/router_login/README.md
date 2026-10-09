# router_login

Controls how one logs in to the OpenWRT router: SSH is key-only, and the root password (for console and LuCI) comes from `router_login_root_password`.

## Purpose

Ansible connects with an SSH key, so SSH password login is unnecessary. Make sure your public key is in `/etc/dropbear/authorized_keys` on the router before running this role, or you will lock yourself out of SSH.

The root password is written to `/etc/shadow` as a SHA-512 hash with a salt derived from the hostname, which keeps repeated runs idempotent.
