# SOL Development Roadmap

## Completed

- `v0.0.1`: runtime package foundation, shared editor contract, launch scripts, and E1M1 design specification.

## Active — Phase 1: E1M1 Graybox (`v0.1.0`)

- Run the editor-generated E1M1 PWAD beside the SOL runtime package.
- Preserve classic Doom statistics and the Episode 1 world-map intermission.
- Use the shared MC setup cockpit from either repository.
- Route every engine/editor launch through the exact locked fourteen-resource wadpack.
- Block launches when the local pack is missing or changed.
- Keep third-party binaries outside public Git history pending license review.
- Complete local Linux playthrough and save/load verification.
- Keep inherited UZDoom compilation checks green.

Exit gate: a clean sibling checkout can configure its IWAD and complete wadpack,
build both applications, launch E1M1 through any supported entry point, complete
the classic intermission, and record no ZScript, MAPINFO, or resource errors.

## Phase 2 — Story Systems (`v0.2.0`)

Add objectives, subtitles, environmental sequences, reusable event IDs, and
save/load-safe story handling. Begin converting tuned wadpack behavior into
SOL-owned defaults.

## Phase 3 — Classic Episode Framework (`v0.3.0`)

Iterate on level-complete screens, episode world map, secret exits, title
patches, par times, and episode-finale presentation.

## Phase 4 — Finished Vertical Slice (`v0.5.0`)

Deliver production mapping, original assets, lighting, soundscape, polished
hordes, benchmarks, and tester builds.

## Phase 5 — Campaign Pipeline (`v0.6.0–v0.8.0`)

Add reusable systems, campaign-state inspection, automated packaging,
provenance manifests, license auditing, and regression maps.

## Phase 6 — Standalone Product (`v0.9.0`)

Complete SOL identity, custom launcher/menu, installers, diagnostics, and a
redistribution-safe embedded or replacement resource stack.

## Phase 7 — Release (`v1.0.0`)

Complete the campaign, stabilize saves, publish credits and corresponding
source, and define maintenance policy.
