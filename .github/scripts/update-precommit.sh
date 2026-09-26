#!/bin/bash
set -e

CHANGED=false

INDICES=$(yq '.repos | to_entries | map(select(.value.repo != "local")) | .[].key' .pre-commit-config.yaml)

for INDEX in $INDICES; do
  export INDEX
  REPO_URL=$(yq '.repos[env(INDEX)].repo' .pre-commit-config.yaml)
  CURRENT_REV=$(yq '.repos[env(INDEX)].rev' .pre-commit-config.yaml)
  OWNER_REPO=${REPO_URL#https://github.com/}
  LATEST_REV=$(curl --silent "https://api.github.com/repos/${OWNER_REPO}/releases/latest" | jq --raw-output '.tag_name')
  if [ "$LATEST_REV" != "null" ] && [ "$LATEST_REV" != "$CURRENT_REV" ]; then
    export LATEST_REV
    yq --inplace '.repos[env(INDEX)].rev = env(LATEST_REV)' .pre-commit-config.yaml
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
