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

## Versioning / updating

- `agent-pi` is pinned via the `@...@PINNED_VERSION` placeholder; replace it
  with a real version and rebuild when you want to move.
- `agent-cursor` fetches latest on install and auto-updates; record the
  installed `cursor-agent --version` (and `agent --version`) in the VPS runbook.
- Rebuild the base layer when you add CLIs or skills dependencies.
