# SOL Development Roadmap

## Completed

- `v0.0.1`: runtime package foundation, shared editor contract, launch scripts, and E1M1 design specification.
- `v0.1.0`: E1M1 runtime contract, classic Doom statistics/world-map progression, corrected ZScript entry point, shared MC cockpit entry, eighteen-resource wadpack contract 2, and bundle contract 1 with canonical `sol.pk3` local runtime packaging.

The original fourteen-resource baseline remains positions 1–14. Wadpack contract
2 appends Universal Ambience, CosmoAmbience Script edited, Ambient decorations,
and TargetSpy v3.1.0 in positions 15–18.

A complete local build now condenses those eighteen normalized resources, the
SOL runtime, current E1M1 content, component hashes, and attribution into one
physical `sol.pk3`. Engine and editor wrappers materialize the intact child
archives from that bundle, so normal runtime use no longer depends on loose
wadpack files after packaging.

`THIRD_PARTY.md` records attribution/provenance, but the complete bundle remains
a local development/test artifact until every third-party redistribution basis
is documented. HQ PlayStation music and sound effects remain local-only inputs.

## Active — Phase 2: Story Systems (`v0.2.0`)

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
redistribution-cleared embedded/replacement resource stack. Move bundle
materialization into the standalone runtime when the final resource set and
rights are stable.

## Phase 7 — Release (`v1.0.0`)

Complete the campaign, stabilize saves, publish credits and corresponding
source, and define maintenance policy.
