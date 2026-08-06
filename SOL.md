# SOL Engine

`sol-engine` is the runtime fork for SOL, a standalone story-driven Doom project based on UZDoom.

## Current release

`v0.1.0-dev` runs the E1M1 graybox authored by `sol-editor` and establishes the map identity, classic episode progression, package, and branding contracts.

SOL keeps Doom's normal level-complete statistics and Episode 1 "you are here" intermission map. Seamless level transfer is not part of the current design.

```bash
bash tools/sol-package.sh
SOL_ENGINE=/path/to/sol-engine-build/uzdoom DOOM_IWAD=/path/to/doom.wad bash tools/sol-run.sh E1M1 /path/to/sol-e1m1-v0.1.0-dev.pk3
```

## Branch policy

- `trunk`: stable integrated SOL work and the upstream-compatible base.
- `sol/vX.Y.Z-*`: active release work.
- `sol/spike-*`: disposable architecture experiments.

Keep upstream synchronization separate from SOL feature commits. Do not commit commercial IWAD data or extracted resources.
