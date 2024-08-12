echo Hostname for machine to be bootstrapped:
set name (read)
ansible-playbook ubuntu-bootstrap.yml --ask-become-pass --inventory=$name,
