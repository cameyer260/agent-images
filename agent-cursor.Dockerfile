# Cursor Agent CLI image: base + Node + the cursor-agent CLI.
# Auth lives in ~/.config/Cursor (mounted rw at runtime), not baked in.
#
# The official installer (~/.local/bin/agent + cursor-agent) fetches the latest
# build and auto-updates; record the installed version in your runbook rather
# than trying to pin a digest here.
FROM agent-base:24.04

USER root
# Node — the cursor-agent bundle runs on Node.
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y nodejs

# Cursor Agent CLI — installs into ~/.local/bin (on the PATH from the base).
USER dev
RUN curl -fsS https://cursor.com/install | bash

USER dev
