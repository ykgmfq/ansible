#!/bin/bash
set -e

CHANGED=false
FILE=roles/requirements.yml
API=https://galaxy.ansible.com/api/v3/plugin/ansible/content/published/collections/index

COUNT=$(yq '.collections | length' "$FILE")
for INDEX in $(seq 0 $((COUNT - 1))); do
  export INDEX
  NAME=$(yq '.collections[env(INDEX)].name' "$FILE")
  CURRENT=$(yq '.collections[env(INDEX)].version // ""' "$FILE")
  LATEST=$(curl --silent --fail "$API/${NAME%.*}/${NAME#*.}/" | jq --raw-output '.highest_version.version')
  if [ -n "$LATEST" ] && [ "$LATEST" != "null" ] && [ "$CURRENT" != "==$LATEST" ]; then
    export PIN="==$LATEST"
    yq --inplace '.collections[env(INDEX)].version = env(PIN)' "$FILE"
    CHANGED=true
  fi
done

if [ -n "$GITHUB_OUTPUT" ]; then
  if [ "$CHANGED" = true ]; then
    echo "result=updated" >> "$GITHUB_OUTPUT"
  else
    echo "result=up-to-date" >> "$GITHUB_OUTPUT"
  fi
fi
