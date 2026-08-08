# SOL Engine

`sol-engine` is the runtime fork for SOL, based on UZDoom.

## Current release

`v0.1.0` provides the E1M1 runtime contract, classic Doom episode progression,
shared SOL branding, the corrected ZScript entry point, and a strict launch path
through the sibling `sol-editor` v0.1.0 eighteen-resource wadpack contract.

## First run

The canonical setup cockpit and locked resource manifest live in the sibling
`sol-editor` checkout:

```bash
bash tools/sol-cockpit.sh
```

After setup:

```bash
bash tools/sol-run.sh E1M1
```

`sol-run.sh` delegates to the editor-side launch contract. This guarantees that
engine launches and editor playtests use the same IWAD, exact eighteen-resource
wadpack order, current SOL runtime package, and current E1M1 package. It does not
fall back to a generic system UZDoom executable.

The original fourteen-resource baseline remains in positions 1–14. Wadpack
contract 2 appends Universal Ambience, CosmoAmbience Script edited, Ambient
decorations, and TargetSpy v3.1.0 as positions 15–18.

The generated runtime package for this release is:

```text
build/sol/sol-v0.1.0.pk3
```

The third-party wadpack remains local under sibling `vend/wadpack`; public
binary embedding is deferred until all redistribution rights are documented.

SOL keeps Doom's normal level-complete statistics and Episode 1 “you are here”
intermission map. Seamless level transfer is not part of the current design.
