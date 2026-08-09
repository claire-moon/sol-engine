# SOL locked wadpack

`sol-engine` owns the canonical resource manifest, importer/locker, final bundle
builder, slot contract, and attribution inventory beginning with v0.4.0.
`sol-editor` consumes these contracts for authoring and playtesting.

## Wadpack contract 3

The logical table contains twenty wadpack slots:

| Slot | State | Component |
|---:|---|---|
| 1–10 | active | existing locked SOL resources |
| 11 | retired | HQ PSX music; never mounted |
| 12–18 | active | existing locked SOL resources |
| 19 | active | PreciseCrosshair v1.5.0 |
| 20 | reserved | intentionally empty; never mounted |

There are still eighteen active wadpack resources. Retired/reserved positions
are retained as metadata so slot identity never shifts when a resource is
removed or a future slot is allocated.

`sol/wadpack.json` is schema 2. Active entries carry source aliases/hashes,
normalized runtime names, transformation rules, distribution state, and the
explicit slot. The lock generated under `vend/wadpack/lock.json` is schema 2 and
records the normalized SHA-256 for every active entry.

## Bundle contract 2

The final local runtime remains one physical file:

```text
sol.pk3
```

`SOLPACK.json` schema 2 contains two related tables:

- `slots`: all logical positions, including retired/reserved positions;
- `components`: only physical mounted carriers.

The physical carrier order is therefore:

```text
01–10  active wadpack resources
12–19  active wadpack resources
21     SOL runtime archive
22     SOL content archive
```

There is no `11-*` or `20-*` archive. Slot 11 and slot 20 exist in metadata only.
This prevents retired/reserved resources from mounting while preserving stable
slot numbers.

The `.wad` suffix on root carriers is an engine embedding convention. The bytes
inside each carrier remain the original normalized WAD/PK3. The inherited
resource filesystem opens those embedded archives by content and mounts them in
lexical order.

## Build and verification

From `sol-engine`:

```bash
bash tools/sol-wadpack-setup.sh
bash tools/sol-bundle.sh
python3 tools/sol-bundle.py verify \
    --bundle build/sol/sol.pk3 \
    --manifest sol/wadpack.json \
    --version-file sol/version.json
```

The final builder obtains the SOL-owned runtime component from this repository
and the current content component from the sibling editor checkout. It verifies
the complete bundle, then copies the identical `sol.pk3` into configured
engine/editor development package locations.

Gameplay never needs eighteen loose `-file` arguments. Native `sol-engine`
validates and mounts adjacent `sol.pk3`; later optional player/developer files
remain possible and mark the run modified under the run-integrity contract.

## Editor consumption

Ultimate Doom Builder requires direct resource paths while authoring. The editor
compatibility entry points therefore delegate wadpack/bundle operations to the
engine-owned tools, and materialization may extract active carriers into a
hash-keyed authoring cache. Retired/reserved slots are never materialized.

The editor still builds the current SOL content component and appends temporary
playtest map data after the canonical bundle so the map under edit retains
playtest precedence.

## Attribution and distribution

`THIRD_PARTY.md` is embedded in the bundle and is provenance/attribution, not a
relicensing mechanism. Complete third-party bundles remain local-only until each
resource and bundled asset has documented redistribution permission.

HQ PlayStation music is retired in slot 11. PlayStation sound effects remain a
local development placeholder in slot 12. PreciseCrosshair v1.5.0 occupies slot
19; its upstream GPL-3.0-only project and bundled libeye notice are recorded for
asset-level review. Slot 20 remains unused for future allocation.
