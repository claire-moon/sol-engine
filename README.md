# SOL Engine

[![Build](https://github.com/claire-moon/sol-engine/actions/workflows/continuous_integration.yml/badge.svg)](https://github.com/claire-moon/sol-engine/actions/workflows/continuous_integration.yml)
[![SOL validation](https://github.com/claire-moon/sol-engine/actions/workflows/sol-foundation.yml/badge.svg)](https://github.com/claire-moon/sol-engine/actions/workflows/sol-foundation.yml)

SOL Engine is the standalone runtime for SOL, a classic Doom-inspired game and
toolchain. It is derived from UZDoom and currently requires a legally obtained
registered Doom or Ultimate Doom IWAD.

The player launches the native `sol-engine` executable. It discovers the IWAD,
validates and mounts the mandatory local `sol.pk3`, and then accepts optional
development files with later override precedence. No wrapper-supplied
`-file sol.pk3` argument is part of the runtime contract.

The complete `sol.pk3` contains third-party development resources whose public
redistribution has not yet been cleared. It is therefore built locally and is
not included in public engine-only artifacts. See [SOL.md](SOL.md) for the
current build, launch, integrity, and licensing contracts, and
[ROADMAP.md](ROADMAP.md) for the engine-first development phases.

## Repository roles

- `sol-engine`: native runtime, gameplay systems, renderer and platform work.
- `sol-editor`: SOL's Ultimate Doom Builder-derived authoring environment and,
  until bundle authority moves in v0.4.0, the local resource importer/builder.

Story and production level authoring are deliberately parked until the runtime
and editor integration phases are complete.

## Development build

Configure and build with CMake, then build the local bundle through the sibling
editor checkout:

```bash
cmake -S . -B build/sol-local -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build/sol-local --parallel
bash tools/sol-bundle.sh
```

Place `sol.pk3` beside `build/sol-local/sol-engine` and launch the executable
directly. `DOOM_IWAD=/absolute/path/to/DOOM.WAD bash tools/sol-run.sh` remains a
development convenience only.

## Upstream and licensing

SOL Engine retains the copyright notices, source history, and license files of
the projects it derives from. Its engine lineage includes Doom, ZDoom, GZDoom,
and UZDoom. New SOL engine code is GPL-3.0-or-later unless a file records a
compatible inherited license. Third-party game resources keep their own terms
and are not relicensed by this repository.

Selected upstream fixes enter through the reviewed process documented in
[docs/sol/upstream-intake.md](docs/sol/upstream-intake.md). See
[CONTRIBUTORS](CONTRIBUTORS), [LICENSE](LICENSE), and
[THIRD_PARTY.md](THIRD_PARTY.md) for details.

Bug reports and feature proposals belong in the
[SOL Engine issue tracker](https://github.com/claire-moon/sol-engine/issues).
