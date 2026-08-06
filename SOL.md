# SOL Engine

`sol-engine` is the runtime fork for SOL, based on UZDoom.

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
engine launches and editor playtests use the same IWAD, exact fourteen-resource
wadpack order, current SOL runtime package, and current E1M1 package. It does not
fall back to a generic system UZDoom executable.

The third-party wadpack remains local under sibling `vend/wadpack`; public
binary embedding is deferred until all redistribution rights are documented.

SOL keeps Doom's normal level-complete statistics and Episode 1 “you are here”
intermission map. Seamless level transfer is not part of the current design.
