#!/usr/bin/fish
set tag (basename (pwd))
set -x USERMAP_UID {{ users.docs }}
set -x USERMAP_GID $USERMAP_UID
set -x PAPERLESS_LOGGING_DIR /tmp/log
echo User ID for scan: $USERMAP_UID
set ctr (buildah from --pull ghcr.io/paperless-ngx/paperless-ngx:{{ versions.paperless }})
and buildah run $ctr mkdir --mode='ugo=rwx' $PAPERLESS_LOGGING_DIR
for e in USERMAP_{G,U}ID PAPERLESS_LOGGING_DIR
    and buildah config --env=$e $ctr
end
and buildah commit --rm $ctr $tag
or exit 1
