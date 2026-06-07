#!/usr/bin/env fish
# Remove files previously deployed by Ansible that are now provided by
# prod-units sysext or home-automation/host-config confext.

set -l units \
    prod.target prod.slice prod-builders.slice prod-tier0.slice prod-tier1.slice \
    image-bootstrap@.service image-build@.service image-build@.timer \
    image-prune.service image-prune.timer

set -l scripts pgupgrade.py plain-secret.py

set -l removed 0

# Unit files in /etc/systemd/system/ (now provided by sysext at /usr/lib/systemd/system/)
for u in $units
    set f /etc/systemd/system/$u
    if test -e $f
        rm -f $f && echo "Removed $f" && set removed (math $removed + 1)
    end
end

# default.target symlink that pointed to the now-removed /etc/systemd/system/prod.target
set dt /etc/systemd/system/default.target
if test -L $dt; and string match -q "*/etc/systemd/system/prod.target" (readlink -f $dt)
    rm -f $dt && echo "Removed $dt (old symlink to /etc/systemd/system/prod.target)" && set removed (math $removed + 1)
end

# Scripts in /usr/local/bin/ (previously placed by Ansible, now provided by sysext at /usr/bin/)
for s in $scripts
    set f /usr/local/bin/$s
    if test -e $f
        rm -f $f && echo "Removed $f" && set removed (math $removed + 1)
    end
end

# Config files now provided by confext
for f in /etc/firewalld/services/homekit.xml /etc/udev/rules.d/conbee.rules \
          /etc/rpm-ostreed.conf \
          /etc/systemd/system/rpm-ostreed-automatic.timer.d/override.conf \
          /root/.config/fish/config.fish
    if test -e $f
        rm -f $f && echo "Removed $f" && set removed (math $removed + 1)
    end
end

# Remove directories left empty after file removal
for d in /etc/systemd/system/rpm-ostreed-automatic.timer.d /root/.config/fish
    if test -d $d; and test -z "$(ls -A $d)"
        rmdir $d && echo "Removed empty dir $d" && set removed (math $removed + 1)
    end
end

if test $removed -gt 0
    echo ""
    echo "Removed $removed file(s). Running daemon-reload..."
    systemctl daemon-reload
    echo "Done. Now run: systemd-sysext merge && systemd-confext merge"
else
    echo "Nothing to clean up."
end
