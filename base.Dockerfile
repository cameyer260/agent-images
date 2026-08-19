# Shared base for the pi agent image.
#
# Provides a non-root `dev` user (matching the host's dev uid/gid via build
# args) plus the common CLIs the skills call: git, ripgrep, fd, jq, gh, bx.
# The playwright package lives inside the skills dir and is NOT installed here.
ARG UBUNTU=24.04
FROM ubuntu:${UBUNTU}

# UID/GID of the host `dev` account. The runtime `--user "$(id -u dev):$(id -g dev)"`
# flag is what really enforces file ownership on the host, but baking matching
# ids keeps the image sane when that flag is absent.
ARG DEV_UID=1000
ARG DEV_GID=1000

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg \
      git ripgrep fd-find jq unzip xz-utils \
 && rm -rf /var/lib/apt/lists/*

# Ubuntu's fd-find ships the binary as `fdfind`; skills expect `fd`.
RUN ln -s "$(command -v fdfind)" /usr/local/bin/fd

# Non-root user. Runtime also overrides to host dev via --user.
# ubuntu:24.04 ships a stock `ubuntu` user/group at uid/gid 1000, which collides
# with the host dev ids we bake in. The stock account is disposable (empty home,
# no credentials), so remove it first, then create dev at the host's ids.
RUN userdel -r ubuntu 2>/dev/null || true \
 && groupdel ubuntu 2>/dev/null || true \
 && groupadd -g ${DEV_GID} dev \
 && useradd -m -u ${DEV_UID} -g dev -s /bin/bash dev

# GitHub CLI (gh) — official Debian/Ubuntu apt repo
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian
# Keyring SHA256 from that page (binary githubcli-archive-keyring.gpg).
RUN install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
 && echo "6084d5d7bd8e288441e0e94fc6275570895da18e6751f70f057485dc2d1a811b  /etc/apt/keyrings/githubcli-archive-keyring.gpg" \
      | sha256sum -c - \
 && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
 && apt-get update && apt-get install -y gh \
 && rm -rf /var/lib/apt/lists/*

# bx (Brave Search CLI) — a downloaded CLI tool the skills call from bash.
# Runs as dev so it lands in ~/.local/bin (picked up by PATH below).
# API key is NOT in the image. On the VPS, once:
#   mkdir -p /home/dev/.config/bx
#   printf 'BRAVE_SEARCH_API_KEY=thekey\n' > /home/dev/.config/bx/bx.env
#   chmod 600 /home/dev/.config/bx/bx.env
# Then every docker run:
#   --env-file /home/dev/.config/bx/bx.env
USER dev
RUN curl -fsSL https://raw.githubusercontent.com/brave/brave-search-cli/main/scripts/install.sh | sh
USER root

ENV HOME=/home/dev
ENV PATH="/home/dev/.local/bin:$PATH"
WORKDIR /workspace
