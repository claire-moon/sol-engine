# SOL Engine

`sol-engine` is the runtime fork for SOL, based on UZDoom.

## Current release

`v0.2.0` begins Phase 2 story systems while preserving the v0.1.0 E1M1,
classic Doom episode progression, branding, wadpack contract 2, and bundle
contract 1 runtime behavior.

Story contract 1 adds stable typed IDs and `SolStoryState`, an undroppable
inventory-backed state object for save-persistent events, objectives, subtitle
history, radio history, and current-objective state. `SolBootstrap` guarantees
that every active player owns exactly one state object on world load, player
entry, and player spawn. The foundation does not invent map narrative content;
concrete IDs and text are authored by the sibling `sol-editor` manifest.

The canonical local runtime payload remains one file:

```text
sol.pk3
```

Bundle contract 1 contains the eighteen normalized third-party WAD/PK3 files,
the SOL runtime, current E1M1 content, `SOLPACK.json`, and `THIRD_PARTY.md`.
Every archive remains byte-for-byte intact inside a numbered root-level `.wad`
carrier.

The carrier suffix deliberately activates UZDoom's existing native embedded-
resource handling. UZDoom recognizes those members as embedded archives, opens
them by actual file contents, and recursively mounts carriers 01→20 in lexical
order. The runtime therefore needs one resource argument:

```text
-file sol.pk3
```

## Local build and run

The canonical bundler lives in the sibling `sol-editor` checkout because that
repository owns the wadpack manifest, importer, map package, story authoring
manifest, and complete attribution inventory.

```bash
cd ../sol-editor
bash tools/sol-wadpack-setup.sh
bash tools/sol-package.sh
```

The bundle builder copies the same `sol.pk3` to `sol-engine/build/sol` and the
configured engine build directory. Local engine builds also install an executable
`sol-engine` launcher beside UZDoom.

From a packaged build directory:

```bash
./sol-engine E1M1
```

The launcher requires/loads adjacent `sol.pk3`. If `DOOM_IWAD` is set it is used;
otherwise UZDoom keeps its normal IWAD discovery/picker.

From the source checkout:

```bash
bash tools/sol-run.sh E1M1
```

`sol-run.sh` uses the same direct self-contained launcher rather than requiring
the sibling editor at runtime.

Once `sol.pk3` exists, loose `vend/wadpack/runtime` files are build inputs rather
than gameplay dependencies.

## Story runtime contract

Story contract 1 reserves IDs 1–65535 within four independent namespaces:
events, objectives, subtitles, and radio cues. `SolStoryState` stores the
contract version plus recorded IDs using save-persistent member fields. Duplicate
records are rejected by its API, completed objectives cannot be restarted, and
completing the current objective clears it.

`SolBootstrap` resolves the player pawn through the native event-handler hooks
and checks for `SolStoryState` with `FindInventory` before using
`GiveInventoryType`. This makes state creation deterministic for new players and
for older saves that do not yet contain the v0.2.0 state object, while preserving
an already-loaded state object instead of creating a duplicate.

This cycle establishes state and compatibility boundaries only. Trigger actors,
HUD presentation, subtitle timing, radio playback, and concrete E1M1 narrative
content are subsequent Phase 2 work.

## Runtime component versus final package

`tools/sol-runtime-package.sh` produces the SOL-owned engine component:

```text
build/sol/sol-v0.2.0.pk3
```

That component is entry 19 inside final `sol.pk3`. It exists separately so source
CI and first-run setup can validate SOL-owned data without possessing third-party
resources.

`tools/sol-package.sh` is the final package entry point. When the sibling editor
and complete wadpack are available it produces/returns `sol.pk3`; during
first-run setup it can temporarily fall back to the SOL-owned component until the
wadpack has been imported.

## Attribution and redistribution

`THIRD_PARTY.md` is committed in both repositories, and the editor's complete
copy is embedded into every `sol.pk3`. The manifest records exact source hashes
and known upstream source pages. Upstream archives remain intact so notices
contained inside them stay with their content.

Attribution is not a substitute for redistribution permission. Several
components still require asset/license review, while HQ PlayStation music and
sound effects remain local-only proprietary inputs. The complete `sol.pk3` is
therefore a local-build development/runtime artifact and must not be published as
a public binary release until the third-party audit is complete.

SOL keeps Doom's normal level-complete statistics and Episode 1 “you are here”
intermission map. Seamless level transfer is not part of the current design.
