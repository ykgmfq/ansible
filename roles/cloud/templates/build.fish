#!/usr/bin/fish
set tag (basename (pwd))
set uid {{ users.cloud }}
set fedora {{ versions.fedora }}
set php {{ versions.php }}
set caddy {{ versions.caddy }}
echo "Base Image  | $fedora"
echo "PHP version | $php"
echo "Tag         | $tag"
echo "User ID     | $uid"
# Web server
echo Web
set ctr (buildah from --pull docker.io/library/caddy:$caddy)
and buildah copy $ctr ./src/Caddyfile /etc/caddy/
and buildah run $ctr apk add --no-cache curl
and buildah commit --rm $ctr $tag-web
or exit 1
# PHP
echo PHP
set ctr (buildah from --pull quay.io/fedora/fedora:$fedora)
and buildah copy $ctr ./src tmp
and buildah config --cmd /sbin/init $ctr
and buildah run $ctr bash /tmp/install.sh $uid $php
and buildah commit --rm $ctr $tag
or exit 1
