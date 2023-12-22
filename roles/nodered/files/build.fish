#!/usr/bin/fish
set tag (basename (pwd))
export (cat ../$tag.ini | xargs -L 1)
echo "Base Image  | $nodejs"
echo "Tag         | $tag"
podman build --pull --tag $tag --build-arg nodejs=$nodejs .
