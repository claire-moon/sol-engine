# SOL Engine

`sol-engine` is the runtime fork for SOL, based on UZDoom.

## Current release

`v0.1.0` provides the E1M1 runtime contract, classic Doom episode progression,
shared SOL branding, the corrected ZScript entry point, and wadpack contract 2
with eighteen fixed third-party resources.

The canonical local runtime payload is one file:

```text
sol.pk3
```

Bundle contract 1 contains the eighteen normalized third-party WAD/PK3 files as
intact embedded archives followed by the SOL runtime and current E1M1 content
components. It also contains `SOLPACK.json` and `THIRD_PARTY.md`.

## Local build and run

The canonical bundler lives in the sibling `sol-editor` checkout because that
repository owns the wadpack manifest, importer, map package, and attribution
inventory.

```bash
cd ../sol-editor
bash tools/sol-wadpack-setup.sh
bash tools/sol-package.sh
```

The bundle builder copies the same `sol.pk3` to `sol-engine/build/sol` and the
configured engine build directory. From `sol-engine` the equivalent entry point
is:

```bash
bash tools/sol-bundle.sh
```

Run E1M1 through the normal wrapper:

```bash
bash tools/sol-run.sh E1M1
```

`sol-run.sh` delegates to the editor-side SOL launcher. The launcher verifies
`sol.pk3`, materializes its child archives into a cache keyed by the complete
bundle hash, then mounts all components in locked order. The loose
`vend/wadpack/runtime` files are therefore build inputs rather than a normal
runtime dependency after `sol.pk3` has been generated.

## Runtime component versus final package

`tools/sol-runtime-package.sh` produces the small SOL-owned engine component:

```text
build/sol/sol-v0.1.0.pk3
```

That component is entry 19 inside the final `sol.pk3`. It exists separately so
source CI and first-run setup can validate SOL-owned data without possessing the
third-party wadpack.

`tools/sol-package.sh` is the final package entry point. When the sibling editor
and complete wadpack are available it produces/returns `sol.pk3`; during
first-run setup it can temporarily fall back to the SOL-owned component until
the wadpack has been imported.

## Attribution and redistribution

`THIRD_PARTY.md` is committed in both repositories, and the editor's complete
copy is embedded into every `sol.pk3`. Each upstream WAD/PK3 remains intact so
notices contained inside the original package remain with it.

Attribution is not a substitute for redistribution permission. Several
components remain `review-required`, while HQ PlayStation music and sound
effects remain recorded as local-only proprietary audio. The complete
`sol.pk3` is therefore currently a local-build development/runtime artifact and
must not be published as a public binary release until the third-party audit is
complete.

SOL keeps Doom's normal level-complete statistics and Episode 1 “you are here”
intermission map. Seamless level transfer is not part of the current design.
