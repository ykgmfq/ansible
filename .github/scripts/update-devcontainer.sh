#!/bin/bash
set -e

LATEST_TAG=$(curl --silent https://mcr.microsoft.com/v2/devcontainers/base/tags/list | jq --raw-output '[.tags[] | select(test("^debian-\\d+$")) | ltrimstr("debian-") | tonumber] | max')
CURRENT_TAG=$(jq --raw-output '.build.args.DEBIAN_TAG' .devcontainer/devcontainer.json)

if [ "$CURRENT_TAG" = "$LATEST_TAG" ]; then
  if [ -n "$GITHUB_OUTPUT" ]; then
    echo "result=up-to-date" >> "$GITHUB_OUTPUT"
  fi
  exit 0
fi
jq --arg tag "$LATEST_TAG" '.build.args.DEBIAN_TAG = $tag' .devcontainer/devcontainer.json > /tmp/devcontainer.json
mv /tmp/devcontainer.json .devcontainer/
if [ -n "$GITHUB_OUTPUT" ]; then
  echo "tag=$LATEST_TAG" >> "$GITHUB_OUTPUT"
  echo "result=updated" >> "$GITHUB_OUTPUT"
fi
echo "$LATEST_TAG"
