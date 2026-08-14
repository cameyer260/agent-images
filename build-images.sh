#!/usr/bin/env bash
# Build the shared base + thin agent images.
#
# Run as `dev` on the VPS (dev is in the docker group, so no sudo needed).
set -euo pipefail
cd "$(dirname "$0")"

# Host dev's uid/gid get baked into the base image's `dev` user.
DEV_UID=$(id -u)
DEV_GID=$(id -g)

echo "==> Building agent-base:24.04 (dev uid=$DEV_UID gid=$DEV_GID)"
docker build --build-arg DEV_UID="$DEV_UID" --build-arg DEV_GID="$DEV_GID" \
  -f base.Dockerfile -t agent-base:24.04 .

echo "==> Building agent-pi:1.0"
docker build -f agent-pi.Dockerfile -t agent-pi:1.0 .

echo "==> Building agent-cursor:1.0"
docker build -f agent-cursor.Dockerfile -t agent-cursor:1.0 .

echo
echo "==> Images:"
docker images | grep -E '^(REPOSITORY|agent-)'
