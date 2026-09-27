INVENTORY := "inventory.yml"
PLAYBOOKS := "playbooks"

# Playbook Check
playbook-check target: lint (_playbook target "--check")

# Playbook Check Verbose
playbook-check-verbose target: lint (_playbook target "--check -vvv")

# Playbook Verbose
playbook-verbose target: lint (_playbook target "-vvv")

# Playbook Normal
playbook target: lint (_playbook target "")

# Router secrets come from Vaultwarden; the homeserver's live on its own pool.
[private]
_playbook target flags:
    {{ if target =~ "^(network|router_prep)$" { "rbw unlock" } else { "true" } }}
    ansible-playbook {{PLAYBOOKS}}/{{target}}.yml -i={{INVENTORY}} --diff {{flags}}

# Run butane to generate ignition file
butane:
    butane --output=server.ign server.butane

# Lint Ansible files and compile Butane
lint:
    ansible-lint
    python3 .github/scripts/nft-lint.py

# Install Galaxy Collections
galaxy:
    ansible-galaxy collection install -r=roles/requirements.yml

ignition: butane
    ip a
    python3 -m http.server 9001
