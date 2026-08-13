# Cursor Agent CLI image: base + the cursor-agent CLI.
# Auth lives in ~/.config/Cursor (mounted rw at runtime), not baked in.
#
# The package bundles its own Node (dist-package/node), so no separate Node
# install is needed here. We download the exact Cursor build from their CDN
# rather than piping the always-latest installer script.
FROM agent-base:24.04

USER root
ARG CURSOR_VERSION=2026.08.11-e8db854
ARG CURSOR_ARCH=x64
RUN mkdir -p /opt/cursor-agent \
 && curl -fsSL "https://downloads.cursor.com/lab/${CURSOR_VERSION}/linux/${CURSOR_ARCH}/agent-cli-package.tar.gz" \
      | tar -xz -C /opt/cursor-agent \
 && ln -s /opt/cursor-agent/dist-package/cursor-agent /usr/local/bin/agent \
 && ln -s /opt/cursor-agent/dist-package/cursor-agent /usr/local/bin/cursor-agent

USER dev
