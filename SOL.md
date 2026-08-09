# SOL Engine

`sol-engine` is the purpose-built runtime fork for SOL. It is derived from
UZDoom, but owns its executable, support archive, application identity, user
state, mandatory gameplay bundle contract, and resource/default policy.

## Current release

`v0.4.0` moves canonical wadpack and `sol.pk3` authority into this repository.
The player still launches the native `sol-engine` binary; no wrapper supplies
`-file sol.pk3`.

A local runtime consists of:

```text
sol-engine
sol-engine.pk3
sol.pk3
```

The engine validates adjacent `sol.pk3` before mounting it. v0.4 requires
SOLPACK schema 2, bundle contract 2, wadpack contract 3, 18 active third-party
resources, 20 logical wadpack slots, runtime slot 21, content slot 22, and the
embedded attribution inventory.

## v0.4 slot contract

The logical resource table is stable even when a slot is not mounted:

- slots 1–10: active inherited wadpack resources;
- slot 11: retired/unmounted HQ PlayStation music;
- slots 12–18: active inherited wadpack resources;
- slot 19: active PreciseCrosshair v1.5.0;
- slot 20: reserved/unmounted;
- slot 21: SOL-owned runtime component;
- slot 22: SOL-owned content component.

Retired and reserved slots exist only in `SOLPACK.json`; they do not consume
dummy embedded archives. Physical root-level `.wad` carriers retain their real
slot prefix, so the mounted archive order is deterministic while gaps remain
explicit.

## Engine-owned build path

The authoritative files are:

```text
sol/wadpack.json
tools/sol-wadpack.py
tools/sol-wadpack-setup.sh
tools/sol-bundle.py
tools/sol-bundle.sh
THIRD_PARTY.md
```

The sibling editor produces the current SOL content component, but no longer
owns resource locking or final bundle construction. With both source checkouts
under the same workspace:

```bash
bash tools/sol-wadpack-setup.sh
bash tools/sol-bundle.sh
```

The local `vend/wadpack` tree holds user-supplied/third-party source and locked
runtime inputs. Complete `sol.pk3` bundles remain local-only until every bundled
asset is cleared for redistribution.

## Native boot order

The fixed runtime order is:

1. `sol-engine.pk3`;
2. optional engine game-support data;
3. a user-owned registered Doom or Ultimate Doom IWAD;
4. mandatory adjacent `sol.pk3`;
5. optional player/developer files.

SOL accepts registered Doom and Ultimate Doom. Doom shareware, Doom II, Final
Doom, and unrelated IWADs are deliberately rejected. Commercial Doom data is
never bundled.

## Canonical defaults

`SOLDEFAULTS.json` contract 1 is packaged inside the SOL-owned runtime
component. It contains only approved renderer, mod, audio, HUD, and gameplay
values. Paths, recent-file history, bindings, saves, and player identity are
excluded.

On a fresh/default profile the engine imports these canonical defaults after
normal CVar defaults are established. The console command
`sol_reset_defaults` reapplies the SOL defaults without importing personal
state.

## Modified runs

SOL exposes read-only `sol_run_modified` and `sol_run_modified_reasons` CVARs
plus `sol_run_status`. Extra files/autoloads, DeHackEd/BEX injection, startup
warps, cheats, console travel, multiplayer/developer overrides, and equivalent
debug paths mark the run modified.

Modified content remains playable, but authoritative progression writes are
disabled through the centralized SOL progression-write guard.

## Build and run

Build the native Linux engine:

```bash
cmake -S . -B build/sol-local -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build/sol-local -j
```

Build the complete local bundle, then launch normally:

```bash
bash tools/sol-bundle.sh
DOOM_IWAD=/path/to/DOOM.WAD bash tools/sol-run.sh
```

Passing a map such as `E1M1` to the development helper is an explicit startup
warp and therefore marks the run modified.

## Attribution and redistribution

`THIRD_PARTY.md` is embedded in every complete bundle. Attribution does not
create redistribution permission. Slot 11 is now retired and never mounted;
slot 12 remains a local PlayStation-sound placeholder; PreciseCrosshair occupies
slot 19 with its upstream GPL/libeye licensing information recorded for review.
The complete third-party bundle remains a local development/test artifact until
all resource-level rights are resolved.
