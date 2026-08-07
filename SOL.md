# SOL Engine

`sol-engine` is the runtime fork for SOL, a standalone story-driven Doom project based on UZDoom.

## Current release

`v0.1.0` runs the E1M1 graybox authored by `sol-editor` and establishes the map identity, classic episode progression, fixed visual/gameplay mod stack, package, and branding contracts.

SOL keeps Doom's normal level-complete statistics and Episode 1 "you are here" intermission map. Seamless level transfer is not part of the current design.

The v0.1.0 runtime requires the eight archives listed in `sol/mods/stack.txt`. Stage them under the sibling `vend/sol-mods` directory, or set `SOL_MOD_ROOT` to the directory containing the exact files. `tools/sol-mod-stack.sh --check` validates the stack before launch. The repository does not download or redistribute those third-party archives.

```bash
bash tools/sol-package.sh
SOL_ENGINE=/path/to/sol-engine-build/uzdoom DOOM_IWAD=/path/to/doom.wad bash tools/sol-run.sh E1M1 /path/to/sol-e1m1-v0.1.0.pk3
```

The launcher uses the local SOL engine and loads the fixed mod stack first, then the SOL runtime package, then any authored content passed on the command line.

## Branch policy

- `trunk`: stable integrated SOL work and the upstream-compatible base.
- `sol/vX.Y.Z-*`: active release work.
- `sol/spike-*`: disposable architecture experiments.

Keep upstream synchronization separate from SOL feature commits. Do not commit commercial IWAD data or third-party mod archives without verified redistribution rights and provenance records.
