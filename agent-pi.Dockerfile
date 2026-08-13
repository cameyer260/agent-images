# Pi agent image: base + Node LTS + the pi agent package.
# Provider config/auth is NOT baked in; it's mounted rw at runtime
# (~/.pi/agent/auth.json) so the auto-refreshing OAuth session persists.
FROM agent-base:24.04

USER root
# Node LTS v24.19.0 — exact version via the official dist tarball (arch auto-detected).
ARG NODE_VERSION=v24.19.0
RUN arch="$(uname -m)"; case "$arch" in \
        x86_64|amd64)  node_arch="x64" ;; \
        aarch64|arm64) node_arch="arm64" ;; \
        *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac \
 && curl -fsSL "https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-${node_arch}.tar.xz" \
      | tar -xJ -C /usr/local --strip-components=1

# Pi agent package v0.84.1
RUN npm install -g @earendil-works/pi-coding-agent@0.84.1

USER dev
