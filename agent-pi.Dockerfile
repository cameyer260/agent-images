# Pi agent image: base + Node + the pi agent package.
# Provider config/auth is NOT baked in; it's mounted rw at runtime
# (~/.pi/agent/auth.json) so the auto-refreshing OAuth session persists.
FROM agent-base:24.04

USER root
# Node LTS — Pi is a Node coding agent.
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y nodejs

# Pin a real version instead of floating on the tag.
RUN npm install -g @earendil-works/pi-coding-agent@PINNED_VERSION

USER dev
