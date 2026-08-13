# Shared base for both agent images.
#
# Provides a non-root `dev` user (matching the host's dev uid/gid via build
# args) plus the common CLIs the skills call: git, ripgrep, fd, jq, gh, bx.
# The playwright package lives inside the skills dir and is NOT installed here.
#
# Note on "root": every RUN in a Dockerfile executes as root inside the image
# unless we `USER dev` first. That is what the plan means by "built as root".
# The human typing `docker build` can be `dev` (via the docker group); that
# does not change how the image layers are built.
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
      git ripgrep fd-find jq unzip \
 && rm -rf /var/lib/apt/lists/*

# Non-root user. Runtime also overrides to host dev via --user.
RUN groupadd -g ${DEV_GID} dev \
 && useradd -m -u ${DEV_UID} -g dev -s /bin/bash dev

# GitHub CLI (gh)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
 && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
 && apt-get update && apt-get install -y gh \
 && rm -rf /var/lib/apt/lists/*

# bx (Brave Search CLI) — a downloaded CLI tool the skills call from bash.
# Runs as dev so it lands in ~/.local/bin (picked up by PATH below).
USER dev
RUN curl -fsSL https://raw.githubusercontent.com/brave/brave-search-cli/main/scripts/install.sh | sh
USER root

ENV HOME=/home/dev
ENV PATH="/home/dev/.local/bin:$PATH"
WORKDIR /workspace
