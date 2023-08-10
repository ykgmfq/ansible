#!/usr/bin/fish
set tag (basename (pwd))
set scan_id (id --user scan)
set -x USERMAP_UID (id --user $tag)
set -x USERMAP_GID $USERMAP_UID
set -x PAPERLESS_LOGGING_DIR /tmp/log
echo User ID for scan: $USERMAP_UID
set ctr (buildah from --pull ghcr.io/paperless-ngx/paperless-ngx)
buildah run $ctr /bin/bash -c "set -e; groupadd --gid $scan_id scan && usermod -aG www-data,scan paperless && mkdir --mode='ugo=rwx' $PAPERLESS_LOGGING_DIR"
for e in USERMAP_{G,U}ID PAPERLESS_LOGGING_DIR
    buildah config --env=$e $ctr
end
buildah commit --rm $ctr $tag
