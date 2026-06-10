INVENTORY := "inventory.yml"
PLAYBOOK := "production.yml"

# Playbook Check
playbook-check: lint
    ansible-playbook {{PLAYBOOK}} -i={{INVENTORY}} --diff --check

# Playbook Check Verbose
playbook-check-verbose: lint
    ansible-playbook {{PLAYBOOK}} -i={{INVENTORY}} --diff --check -vvv

# Playbook Verbose
playbook-verbose: lint
    ansible-playbook {{PLAYBOOK}} -i={{INVENTORY}} --diff -vvv

# Playbook Normal
playbook: lint
    ansible-playbook {{PLAYBOOK}} -i={{INVENTORY}} --diff

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
