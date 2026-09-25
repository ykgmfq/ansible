INVENTORY := "inventory.yml"
PLAYBOOKS := "playbooks"

# Playbook Check
playbook-check target: lint
    ansible-playbook {{PLAYBOOKS}}/{{target}}.yml -i={{INVENTORY}} --diff --check

# Playbook Check Verbose
playbook-check-verbose target: lint
    ansible-playbook {{PLAYBOOKS}}/{{target}}.yml -i={{INVENTORY}} --diff --check -vvv

# Playbook Verbose
playbook-verbose target: lint
    ansible-playbook {{PLAYBOOKS}}/{{target}}.yml -i={{INVENTORY}} --diff -vvv

# Playbook Normal
playbook target: lint
    ansible-playbook {{PLAYBOOKS}}/{{target}}.yml -i={{INVENTORY}} --diff

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
