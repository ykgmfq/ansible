#!/usr/bin/env fish
function boot_strap -a host hostname -d "Setup public key login for root and remove the default ubuntu user."
    set pw (pwqgen)
    echo -e "Please set the new password to:\n$pw\nand exit the remote session."
    ssh ubuntu@$host
    if test $status = 0
        echo "Now starting ansible playbook."
        ansible-playbook ubuntu-bootstrap.yml --extra-vars="ansible_password=$pw hostname=$hostname" --extra-vars="@secrets.yml" --vault-password-file=pw.txt -i $host,
    else
        echo "Non-clean exit from ssh"
        exit 1
    end
end
boot_strap $argv
