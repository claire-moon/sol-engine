# SOL Engine

`sol-engine` is the runtime fork for **SOL**, a standalone story-driven Doom project built on UZDoom.

The project keeps UZDoom's `trunk` branch available as the upstream-compatible base. SOL work is developed on `sol/*` branches and merged through reviewable pull requests.

## Responsibilities

- Build and package the SOL runtime.
- Host campaign-state and transition systems.
- Provide deterministic hooks used by SOL maps and tools.
- Preserve compatibility with supported UZDoom mod formats where practical.
- Produce Linux and Windows development builds.

## v0.0.1 quick start

```bash
bash tools/sol-package.sh
SOL_ENGINE=/path/to/uzdoom DOOM_IWAD=/path/to/doom.wad \
  bash tools/sol-run.sh E1M1
```

The `v0.0.1` package is a development foundation. It contains the SOL runtime bootstrap and project metadata; the E1M1 map source is built by `sol-editor` and loaded alongside the generated PK3.

## Branch policy

- `trunk`: synchronized engine base and stable SOL integrations.
- `sol/vX.Y.Z-*`: active release work.
- `sol/spike-*`: disposable architecture experiments.
- Changes to engine internals require a focused issue, validation notes, and a draft pull request.

## Upstream relationship

This repository is derived from UZDoom. Upstream copyright, license, attribution, and asset-specific terms remain in force. SOL-specific code and content must not remove or obscure those notices.

## Content policy

Do not commit commercial Doom IWAD data, extracted textures, sounds, sprites, or music. Development may target a legally obtained IWAD, while distributable SOL content must use original or appropriately licensed assets.