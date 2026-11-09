# Personal repo: inventory, group_vars and other device-specific values.
export PERSONAL_DIR := env("PERSONAL_DIR", justfile_directory() / "personal")
INVENTORY := PERSONAL_DIR / "inventory.yml"
PLAYBOOKS := "playbooks"

# Playbook Check
playbook-check target *flags: lint (_playbook target "--check " + flags)

# Playbook Check Verbose
playbook-check-verbose target *flags: lint (_playbook target "--check -vvv " + flags)

# Playbook Verbose
playbook-verbose target *flags: lint (_playbook target "-vvv " + flags)

# Playbook Normal
playbook target *flags: lint (_playbook target flags)

# Unlock rbw only when Vaultwarden-backed roles run; the homeserver's secrets live on its own pool.
[private]
_playbook target flags:
    test -f {{INVENTORY}} || { echo "Personal repo missing at {{PERSONAL_DIR}}" >&2; exit 1; }
    {{ if flags =~ "--skip-tags[= ][^ ]*secrets" { "true" } else if target =~ "^(network|router_prep|servers)$" { "rbw unlock" } else { "true" } }}
    ansible-playbook {{PLAYBOOKS}}/{{target}}.yml -i={{INVENTORY}} --diff {{flags}}

# Run butane to generate ignition file
butane:
    butane --output=server.ign server.butane

# Lint Ansible files and compile Butane
lint:
    ansible-lint
    python3 .github/scripts/nft-lint.py

# Write every WireGuard client's config to output/ and print each as a QR code
wireguard-client-config *flags:
    rbw unlock
    python3 .github/scripts/wireguard-client-config.py {{flags}}

# Install Galaxy Collections
galaxy:
    ansible-galaxy collection install -r=roles/requirements.yml

ignition:
    ip a
    python3 -m http.server 9001
