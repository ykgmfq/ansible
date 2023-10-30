#!/usr/bin/fish
set tag (basename (pwd))
set uid {{ users.cloud }}
set fedora 38
set php '8.1'
echo "Base Image  | $fedora"
echo "PHP version | $php"
echo "Tag         | $tag"
echo "User ID     | $uid"
# Web server
echo Web
begin
    set ctr (buildah from --pull docker.io/library/caddy:2)
    buildah copy $ctr ./src/Caddyfile /etc/caddy/; or false
    buildah run $ctr apk add --no-cache curl; or false
    buildah commit --rm $ctr $tag-web
end
# PHP
echo PHP
begin
    set ctr (buildah from --pull quay.io/fedora/fedora:$fedora)
    buildah copy $ctr ./src tmp; or false
    buildah config --cmd /sbin/init $ctr
    buildah run $ctr bash /tmp/install.sh $uid $php; or false
    buildah commit --rm $ctr $tag
end
