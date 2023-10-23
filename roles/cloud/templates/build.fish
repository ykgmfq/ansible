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
begin
    set ctr (buildah from --pull docker.io/library/caddy:2)
    buildah copy $ctr ./src/Caddyfile /etc/caddy/; or false
    buildah run $ctr apk add --no-cache curl; or false
    buildah commit --rm $ctr $tag-web
end
# PHP
begin
    set ctr (buildah from --pull quay.io/fedora/fedora:$fedora)
    buildah copy $ctr ./src tmp; or false
    buildah config \
        --port $port \
        --cmd /sbin/init \
        $ctr
    buildah run $ctr /tmp/install.sh $uid $php; or false
    buildah commit --rm $ctr $tag
end
