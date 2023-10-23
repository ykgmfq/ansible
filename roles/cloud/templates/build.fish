#!/usr/bin/fish
export (cat config.ini | xargs -L 1)
set tag (basename (pwd))
set uid (id --user $tag)
echo "Base Image  | $fedora"
echo "PHP version | $php"
echo "Port        | $port"
echo "Tag         | $tag"
echo "User ID     | $uid"
# Web server
set ctr (buildah from --pull docker.io/library/caddy:2)
buildah copy $ctr ./src/Caddyfile /etc/caddy/
buildah commit --rm $ctr $tag-web
# PHP
set ctr (buildah from --pull quay.io/fedora/fedora:$fedora)
#set ctr (buildah from --pull quay.io/fedora/fedora-minimal:$fedora)
buildah copy $ctr ./src tmp
buildah config \
    --port $port \
    --cmd /sbin/init \
    $ctr
echo buildah $status
if test $status -ne 0
    exit 1
end
buildah run $ctr /tmp/install.sh $uid $php
buildah commit --rm $ctr $tag
