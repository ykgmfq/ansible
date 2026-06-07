INVENTORY := "inventory.yml"
PLAYBOOK := "production.yml"

# Playbook Check
playbook-check:
    ansible-playbook {{PLAYBOOK}} -i={{INVENTORY}} --diff --check

# Playbook Check Verbose
playbook-check-verbose:
    ansible-playbook {{PLAYBOOK}} -i={{INVENTORY}} --diff --check -vvv

# Playbook Verbose
playbook-verbose:
    ansible-playbook {{PLAYBOOK}} -i={{INVENTORY}} --diff -vvv

# Playbook Normal
playbook:
    ansible-playbook {{PLAYBOOK}} -i={{INVENTORY}} --diff

# Run butane to generate ignition file
butane:
    butane --output=server.ign server.butane

# Install Galaxy Collections
galaxy:
    ansible-galaxy collection install -r=roles/requirements.yml

ignition:
    ip a
    python3 -m http.server 9001
