INVENTORY := "inventory.yml"
SECRETS := "secrets.yml"
VAULT := "pw.txt"
PLAYBOOK := "production.yml"

# Playbook Check
playbook-check:
    ansible-playbook {{PLAYBOOK}} -i={{INVENTORY}} --extra-vars=@{{SECRETS}} --vault-password-file={{VAULT}} --diff --check

# Playbook Check Verbose
playbook-check-verbose:
    ansible-playbook {{PLAYBOOK}} -i={{INVENTORY}} --extra-vars=@{{SECRETS}} --vault-password-file={{VAULT}} --diff --check -vvv

# Playbook Verbose
playbook-verbose:
    ansible-playbook {{PLAYBOOK}} -i={{INVENTORY}} --extra-vars=@{{SECRETS}} --vault-password-file={{VAULT}} --diff -vvv

# Playbook Normal
playbook:
    ansible-playbook {{PLAYBOOK}} -i={{INVENTORY}} --extra-vars=@{{SECRETS}} --vault-password-file={{VAULT}} --diff

# Run butane to generate ignition file
butane:
    butane --out-file=server.ign server.butane

# Install Galaxy Collections
galaxy:
    ansible-galaxy collection install -r=roles/requirements.yml

ignition:
    ip a
    python3 -m http.server 9001
