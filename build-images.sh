#!/usr/bin/env bash
# Build the shared base + thin agent images.
#
# Run as `dev` on the VPS (dev is in the docker group, so no sudo needed).
set -euo pipefail
# Resolve to the real script location even when invoked via a symlink (jarvis
# installs ~/bin/build-images.sh as a link into agent-images).
cd "$(dirname "$(realpath "$0")")"

# Host dev's uid/gid get baked into the base image's `dev` user.
DEV_UID=$(id -u)
DEV_GID=$(id -g)

echo "==> Building agent-base (dev uid=$DEV_UID gid=$DEV_GID)"
docker build --build-arg DEV_UID="$DEV_UID" --build-arg DEV_GID="$DEV_GID" \
  -f base.Dockerfile -t agent-base .

echo "==> Building agent-pi"
docker build -f agent-pi.Dockerfile -t agent-pi .

echo
echo "==> Images:"
docker images | grep -E '^(REPOSITORY|agent-)'
