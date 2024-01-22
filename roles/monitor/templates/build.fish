#!/usr/bin/fish
set tag (basename (pwd))
function abort
    buildah rm $argv
    exit 1
end
set ubuntu "23.10"
echo "Base Image  | Ubuntu $ubuntu"
echo "Tag         | $tag"
set ctr (buildah from --pull docker.io/ubuntu:$ubuntu)
and buildah copy $ctr ./src tmp
and buildah config --cmd /usr/sbin/init $ctr
and buildah run $ctr bash /tmp/install.sh $uid
and buildah commit --rm $ctr $tag
or abort $ctr
