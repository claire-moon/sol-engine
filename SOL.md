# SOL Engine

`sol-engine` is the runtime fork for SOL, a standalone story-driven Doom project based on UZDoom.

## Current release

`v0.1.0` runs the E1M1 graybox authored by `sol-editor` and establishes the map identity, classic episode progression, package, branding, and mandatory presentation/gameplay stack contracts.

SOL keeps Doom's normal level-complete statistics and Episode 1 "you are here" intermission map. Seamless level transfer is not part of the current design.

The required mod order is defined once in `sol/mods/stack.json`. The third-party files are user-supplied and are not committed or redistributed by this repository. `sol-editor` stages them under the sibling `vend/mods/runtime` directory and exports `SOL_MOD_ROOT` in `.sol-env`.

```bash
source ../sol-editor/.sol-env
bash tools/sol-package.sh
bash tools/sol-run.sh E1M1 -file ../sol-editor/build/sol/sol-e1m1-v0.1.0.pk3
```

`tools/sol-run.sh` is the supported v0.1.0 runtime entrypoint. It requires a locally built `sol-engine`, refuses to fall back to a generic system UZDoom, validates all mandatory stack files before launch, and loads them in the manifest order. Direct raw `uzdoom` invocation does not enforce this launcher contract; binary-level embedding is reserved for standalone-product hardening.

## Branch policy

- `trunk`: stable integrated SOL work and the upstream-compatible base.
- `sol/vX.Y.Z-*`: active release work.
- `sol/spike-*`: disposable architecture experiments.

Keep upstream synchronization separate from SOL feature commits. Do not commit commercial IWAD data or third-party mod payloads without an explicit redistribution license and provenance record.
