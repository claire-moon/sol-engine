# SOL locked wadpack

The authoritative resource manifest, importer, bundle builder, and full
attribution inventory live in the sibling `sol-editor` repository.

Wadpack contract 2 preserves the original fourteen resources in positions 1–14
and appends Universal Ambience, CosmoAmbience Script edited, Ambient decorations,
and TargetSpy v3.1.0 in positions 15–18.

## Final runtime package

The normal local runtime is one physical file:

```text
sol.pk3
```

Bundle contract 1 stores all twenty ordered components as root-level numbered
`.wad` carriers:

```text
01–18  third-party WAD/PK3 archives
19     SOL runtime archive
20     SOL E1M1 content archive
```

The `.wad` suffix is a native carrier convention only. The bytes remain the
original normalized WAD/PK3 archives. UZDoom's existing filesystem recognizes
root-level `.wad` members as embedded resources, opens each by actual content,
and recursively mounts them in lexical 01→20 order.

Gameplay therefore uses exactly:

```text
-file sol.pk3
```

No gameplay extraction layer or eighteen loose `-file` arguments are needed.
`SOLPACK.json` records carrier names, original normalized names, component order,
distribution status, and SHA-256 values. `THIRD_PARTY.md` is embedded for
attribution/provenance.

Ultimate Doom Builder still needs direct resource paths for authoring, so the
editor may materialize entries 1–18 from the bundle into a hash-keyed cache.
Editor playtests return to the one-file native `sol.pk3` path.

Once `sol.pk3` exists and verifies against the current contract, loose files
under sibling `vend/wadpack/runtime` are build inputs rather than gameplay
runtime dependencies.

## Package entry points

From `sol-engine`:

```bash
bash tools/sol-bundle.sh
bash tools/sol-package.sh
bash tools/sol-run.sh E1M1
```

Local engine builds install `sol-engine` beside UZDoom and copy `sol.pk3` beside
it. The packaged launcher loads adjacent `sol.pk3` automatically, uses
`DOOM_IWAD` when supplied, and otherwise leaves UZDoom's normal IWAD picker
intact.

`tools/sol-runtime-package.sh` remains the source-only SOL engine component
builder used by CI and first-run bootstrap.

## Attribution and licensing

Third-party accreditation/provenance is recorded in `THIRD_PARTY.md`; the full
editor copy is embedded in `sol.pk3`, and upstream archives are preserved intact
with notices they already contain.

Universal Ambience's published distribution lists its three ambience components
and labels the package GPL, but it also credits externally sourced audio; the
CosmoAmbience copy supplied to SOL is an edited variant. TargetSpy v3.1.0
explicitly declares GPL-3.0-only and © 2026 Alexander Kromm. Those facts are
recorded without treating them as blanket clearance for unrelated assets.

Attribution does not grant redistribution permission. Several entries still
require asset/license review; HQ PlayStation music and sound effects remain
local-only proprietary audio. Complete `sol.pk3` is therefore a local
development/test build artifact, not yet a public SOL binary release.
