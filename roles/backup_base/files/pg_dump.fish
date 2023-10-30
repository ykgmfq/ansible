#!/usr/bin/fish
set db (basename $SANOID_TARGET)
set uid (id --user $db)
set path (zfs get mountpoint -H -o value $SANOID_TARGET)
set file (printf "%s/pgdump_%s" $path $db)

chmod u+w $file
umask u=rw,go-rwx
systemd-run --quiet --wait --collect --pipe --same-dir --service-type=oneshot --uid $uid /usr/bin/pg_dump --format=custom --file=$file $db
chgrp postgres $file
chmod u-wx,go-rwx $file
