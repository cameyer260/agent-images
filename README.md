# agent-images

Dockerfiles for the VPS agent containers described in `vps-plan.md` Phase 7.

- `base.Dockerfile` — shared base: Ubuntu 24.04, a non-root `dev` user, and the
  CLIs the skills call (`git`, `ripgrep`, `fd`, `jq`, `gh`, `bx`).
- `agent-pi.Dockerfile` — base + Node + `@earendil-works/pi-coding-agent`.
  Pi is an npm package and needs Node at install and runtime (`>=22.19.0`).
- `agent-cursor.Dockerfile` — base + the `cursor-agent` CLI.
- `build-images.sh` — builds all three; run as `dev` on the VPS.

## Layout / workflow

Source of truth is this Git repo. Clone it on the VPS under
`/home/dev/agent-images` (dev-owned, no sudo needed), then run the build script:

```bash
git clone <repo-url> /home/dev/agent-images
cd /home/dev/agent-images
chmod +x build-images.sh
./build-images.sh
```

## Credentials (never baked in)

OAuth tokens are mounted rw at runtime so the auto-refreshing sessions persist
on the host:

- Pi:      `-v /home/dev/.pi/agent/auth.json:/home/dev/.pi/agent/auth.json`
- Cursor:  `-v /home/dev/.config/Cursor:/home/dev/.config/Cursor`
- Skills:  `-v /home/dev/.agents/skills:/home/dev/.agents/skills:ro`

Brave Search (`bx`) uses a host env file, not an image layer. Create it once
on the VPS as `dev`:

```bash
mkdir -p /home/dev/.config/bx
printf 'BRAVE_SEARCH_API_KEY=thekey\n' > /home/dev/.config/bx/bx.env
chmod 600 /home/dev/.config/bx/bx.env
```

Pass it on every `docker run` (both `agent-pi` and `agent-cursor`):

```bash
--env-file /home/dev/.config/bx/bx.env
```

You log into Pi/Cursor once with the auth mounts; the Brave key is the env file.

## Versions (hardcoded in the Dockerfiles)

| Tool | Where it's defined | Version |
|---|---|---|
| Pi agent | `agent-pi.Dockerfile` npm install | `@earendil-works/pi-coding-agent@0.84.1` |
| Node (Pi) | `agent-pi.Dockerfile` `NODE_VERSION` | `v24.19.0` (LTS) |
| Cursor CLI | `agent-cursor.Dockerfile` `CURSOR_VERSION` | `2026.08.11-e8db854` |
| gh, bx, git, rg, fd, jq | `base.Dockerfile` | from the Ubuntu 24.04 apt repo / their installers |

Upgrade by editing the exact version in the Dockerfile and rebuilding.

## Updating

To bump a tool, change its exact version in the relevant Dockerfile and re-run
`build-images.sh`. Rebuild the base layer when you add CLIs
or skills dependencies.
