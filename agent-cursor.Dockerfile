# Cursor Agent CLI image: base + the cursor-agent CLI.
# Auth lives in ~/.config/Cursor (mounted rw at runtime), not baked in.
#
# Same linux-x64 tarball the official installer downloads
# (https://cursor.com/docs/cli/installation → curl cursor.com/install | bash).
# We hit the CDN URL directly so the version stays pinned; the install script
# always embeds whatever build is current. The package bundles its own Node.
FROM agent-base:24.04

USER root
ARG CURSOR_VERSION=2026.08.11-e8db854
RUN mkdir -p /opt/cursor-agent \
 && curl -fsSL "https://downloads.cursor.com/lab/${CURSOR_VERSION}/linux/x64/agent-cli-package.tar.gz" \
      | tar -xz -C /opt/cursor-agent \
 && ln -s /opt/cursor-agent/dist-package/cursor-agent /usr/local/bin/agent \
 && ln -s /opt/cursor-agent/dist-package/cursor-agent /usr/local/bin/cursor-agent

USER dev
