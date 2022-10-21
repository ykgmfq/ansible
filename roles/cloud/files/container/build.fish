#!/usr/bin/fish
set tag (basename (pwd))
set uid (id --user $tag)
export (cat ../$tag.ini | xargs -L 1)
echo "Base Image  | $fedora"
echo "PHP version | $php"
echo "Port        | $port"
echo "Tag         | $tag"
echo "User ID     | $uid"
podman build --pull --tag $tag --build-arg id=$uid --build-arg fedora=$fedora --build-arg php=$php --build-arg port=$port .
