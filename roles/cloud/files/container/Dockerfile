arg fedora
from quay.io/fedora/fedora-minimal:${fedora}
arg id
arg php
arg port
copy ./src tmp
run bash /tmp/install.sh $id $php
expose $port
cmd [ "/sbin/init" ]
