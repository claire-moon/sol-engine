# SOL Engine

`sol-engine` is the purpose-built runtime fork for SOL. It is derived from
UZDoom, but it has its own executable, support archive, application identity,
runtime contract, and user-data namespace.

## Current release

`v0.3.0` establishes native SOL identity and boot. The player launches the
actual `sol-engine` binary; a wrapper no longer supplies `-file sol.pk3`.

The files beside a local runtime binary are:

```text
sol-engine
sol-engine.pk3
sol.pk3
```

`sol-engine.pk3` is engine support data built from this repository. `sol.pk3`
is the distinct mandatory gameplay bundle built from the locked local resource
stack. The engine opens `sol.pk3` itself and validates `SOLPACK.json`,
`THIRD_PARTY.md`, bundle contract 1, wadpack contract 2, all 18 wadpack entries,
and all 20 logical components before mounting it.

The fixed runtime order is:

1. `sol-engine.pk3`
2. optional engine game-support data
3. a user-owned registered Doom or Ultimate Doom IWAD
4. mandatory adjacent `sol.pk3`
5. optional player/developer files

SOL accepts `DOOM.WAD` and `DOOMU.WAD`. Doom shareware, Doom II, Final Doom,
and unrelated IWADs are deliberately rejected. When automatic discovery finds
no supported IWAD, SOL opens a branded native file picker and remembers the
selected directory. Commercial Doom data is never bundled.

## Build and run

Build the native Linux engine:

```bash
cmake -S . -B build/sol-local -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build/sol-local -j
```

The canonical gameplay bundler remains in the sibling `sol-editor` checkout
until authority moves to the engine in v0.4.0:

```bash
cd ../sol-editor
bash tools/sol-wadpack-setup.sh
bash tools/sol-package.sh
```

Copy or build the resulting `sol.pk3` beside `build/sol-local/sol-engine`, then
launch without a resource argument:

```bash
./build/sol-local/sol-engine
```

`DOOM_IWAD=/path/to/DOOM.WAD bash tools/sol-run.sh` is a development helper.
An optional first positional map such as `E1M1` becomes an explicit `+map`
development warp and marks that run modified. The native executable, not the
helper, owns bundle discovery and validation.

## Isolated profile state

All standard paths derive from the SOL names in `version.h`. A normal Linux
profile uses `~/.config/sol-engine/sol-engine.ini` and SOL-specific data/save
and cache directories. Windows uses `My Games/SOL Engine` and SOL-specific
Local AppData/Saved Games paths. macOS uses SOL Engine application-support and
preference paths. No migration path reads or writes a UZDoom profile.

The engine signature is `SOLENGINE`; SOL saves are not silently treated as
UZDoom saves. The UZDoom binary updater is disabled. Upstream changes enter
through the reviewed process in `docs/sol/upstream-intake.md`.

## Canonical and modified runs

SOL exposes read-only `sol_run_modified` and `sol_run_modified_reasons` CVARs
plus the `sol_run_status` console command. Extra files or autoloads, DeHackEd or
BEX injection, startup warps, cheats, console travel, multiplayer/developer
overrides, and equivalent debug launch paths mark the run modified.

Modified content remains playable, but authoritative campaign/progression
writes are disabled. Every future persistent progression surface must call
`SOL_AllowProgressionWrite` (or test `SOL_CanWriteProgression`) before writing.
Reason ordering is fixed so diagnostics are deterministic, and the reason mask
is serialized into saves so a modified run cannot become canonical after load.

## Preserved contracts

Story contract 1 and its save-persistent state machinery remain supported, but
story content is parked while engine work is active. Bundle contract 1,
wadpack contract 2, 18 locked third-party entries, and classic E1M1 progression
remain unchanged in v0.3.0.

The outer `sol.pk3` still stores numbered root-level `.wad` carrier archives.
SOL inherits UZDoom's native embedded-resource handling to recursively mount
those carriers; it does not add a second archive loader.

`tools/sol-runtime-package.sh` produces the SOL-owned component
`build/sol/sol-v0.3.0.pk3`. It is a source/CI artifact, not a substitute for the
complete mandatory `sol.pk3`.

## Attribution and redistribution

`THIRD_PARTY.md` stays embedded in every complete bundle. Attribution does not
grant redistribution permission, so the complete third-party bundle remains a
local development artifact until every asset is cleared.

PlayStation music was included accidentally. Contract 2 still mounts that fixed
slot in v0.3.0, so it can remain audible in this transitional development
build; v0.4.0 retires and unmounts it when bundle authority moves here.
PlayStation sound effects remain only as local-development placeholders until
they are replaced with original user-supplied SOL sounds. Those replacements do
not automatically clear the independent rights of other bundled resources.
