# SOL locked wadpack

The authoritative resource manifest, importer, bundle builder, and full
attribution inventory live in the sibling `sol-editor` repository.

Wadpack contract 2 preserves the original fourteen resources in positions 1–14
and appends Universal Ambience, CosmoAmbience Script edited, Ambient decorations,
and TargetSpy v3.1.0 in positions 15–18.

## Final runtime package

The normal local runtime is a single physical file:

```text
sol.pk3
```

Bundle contract 1 stores the eighteen normalized third-party WAD/PK3 resources
as intact child archives followed by:

```text
19-sol-runtime.pk3
20-sol-content.pk3
```

`SOLPACK.json` records component order and SHA-256 values, and
`THIRD_PARTY.md` is embedded for attribution/provenance.

The resources are not flattened into one ZIP namespace because separate Doom
mods can contain identically named root resources. Keeping the children intact
preserves their normal ordered-load semantics. The SOL launcher materializes
these children from `sol.pk3` into a hash-keyed cache immediately before engine
startup.

Once `sol.pk3` exists and verifies against the current contract, loose files
under sibling `vend/wadpack/runtime` are no longer required for normal runtime
or editor use. They remain build inputs when regenerating the bundle.

## Package entry points

From `sol-engine`:

```bash
bash tools/sol-bundle.sh
bash tools/sol-package.sh
```

Both converge on the sibling editor bundler when the complete local wadpack is
available. `tools/sol-runtime-package.sh` remains the source-only engine
component builder used by CI and first-run bootstrap.

## Attribution and licensing

Third-party accreditation/provenance is recorded in `THIRD_PARTY.md`; the full
editor copy is embedded in `sol.pk3`, and upstream archives are preserved intact
with any notices they already contain.

This does not grant redistribution permission. Several entries remain
`review-required`; HQ PlayStation music and sound effects remain recorded as
local-only proprietary audio. The complete `sol.pk3` is therefore currently
approved only as a local development/test build artifact, not as a public SOL
binary release.
