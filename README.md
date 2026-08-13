# agent-images

Dockerfiles for the VPS agent containers described in `vps-plan.md` Phase 7.

- `base.Dockerfile` — shared base: Ubuntu 24.04, a non-root `dev` user, and the
  CLIs the skills call (`git`, `ripgrep`, `fd`, `jq`, `gh`, `bx`).
- `agent-pi.Dockerfile` — base + Node + `@earendil-works/pi-coding-agent`.
- `agent-cursor.Dockerfile` — base + Node + the `cursor-agent` CLI.
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

Building as `dev` is fine: `dev` is in the `docker` group (Phase 6), so it can
talk to the daemon. The Dockerfile `RUN` layers still *execute* as root inside
each image — that is what the plan means by "built as root" — but it does not
require you to run `docker build` as the `root` account.

## Credentials (never baked in)

Tokens are mounted rw at runtime so the auto-refreshing OAuth sessions persist
on the host:

- Pi:      `-v /home/dev/.pi/agent/auth.json:/home/dev/.pi/agent/auth.json`
- Cursor:  `-v /home/dev/.config/Cursor:/home/dev/.config/Cursor`
- Skills:  `-v /home/dev/.agents/skills:/home/dev/.agents/skills:ro`

Login once per image from an interactive container run (or an interactive `dev`
shell) and let the mount persist it.

## Versions (hardcoded in the Dockerfiles)

| Tool | Where it's defined | Version |
|---|---|---|
| Pi agent | `agent-pi.Dockerfile` npm install | `@earendil-works/pi-coding-agent@0.84.1` |
| Node (Pi) | `agent-pi.Dockerfile` `NODE_VERSION` | `v24.19.0` (LTS) |
| Cursor CLI | `agent-cursor.Dockerfile` `CURSOR_VERSION` | `2026.08.11-e8db854` |
| gh, bx, git, rg, fd, jq | `base.Dockerfile` | from the Ubuntu 24.04 apt repo / their installers |

`.x`-versions aren't used; upgrade by editing the exact version in the
Dockerfile and rebuilding. The Cursor package bundles its own Node, so the
cursor image has no separate Node install.

## Updating

To bump a tool, change its exact version in the relevant Dockerfile and re-run
`build-images.sh` (e.g. `npm view @earendil-works/pi-coding-agent version` for
Pi, `curl -fsS https://cursor.com/install | grep -oE 'lab/[0-9.]+-[a-f0-9]+'`
for the current Cursor build string). Rebuild the base layer when you add CLIs
or skills dependencies. Record what's installed (`pi --version`,
`cursor-agent --version`) in the VPS runbook.
