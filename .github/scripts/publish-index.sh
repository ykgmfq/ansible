#!/bin/bash
# Re-tag the pushed sha image as an index carrying every tag and annotation from docker/metadata-action.
# Needs META (its JSON output) and IMAGE.
set -euo pipefail
: "${META:?}" "${IMAGE:?}"

mapfile -t args < <(jq -r '(.tags[] | "-t", .), (.annotations[] | "--annotation", .)' <<<"$META")
docker buildx imagetools create "${args[@]}" "$IMAGE:sha-${GITHUB_SHA::7}"
