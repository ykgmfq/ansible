INVENTORY := "inventory.yml"
PLAYBOOKS := "playbooks"

# Playbook Check
playbook-check target: lint
    ansible-playbook {{PLAYBOOKS}}/{{target}}.yml -i={{INVENTORY}} --diff --check {{ if target == "network" { "--vault-password-file=.vault-pass" } else if target == "router_prep" { "--vault-password-file=.vault-pass" } else { "" } }}

# Playbook Check Verbose
playbook-check-verbose target: lint
    ansible-playbook {{PLAYBOOKS}}/{{target}}.yml -i={{INVENTORY}} --diff --check -vvv {{ if target == "network" { "--vault-password-file=.vault-pass" } else if target == "router_prep" { "--vault-password-file=.vault-pass" } else { "" } }}

# Playbook Verbose
playbook-verbose target: lint
    ansible-playbook {{PLAYBOOKS}}/{{target}}.yml -i={{INVENTORY}} --diff -vvv {{ if target == "network" { "--vault-password-file=.vault-pass" } else if target == "router_prep" { "--vault-password-file=.vault-pass" } else { "" } }}

# Playbook Normal
playbook target: lint
    ansible-playbook {{PLAYBOOKS}}/{{target}}.yml -i={{INVENTORY}} --diff {{ if target == "network" { "--vault-password-file=.vault-pass" } else if target == "router_prep" { "--vault-password-file=.vault-pass" } else { "" } }}

# Run butane to generate ignition file
butane:
    butane --output=server.ign server.butane

# Lint Ansible files and compile Butane
lint:
    ansible-lint

# Install Galaxy Collections
galaxy:
    ansible-galaxy collection install -r=roles/requirements.yml

ignition: butane
    ip a
    python3 -m http.server 9001
