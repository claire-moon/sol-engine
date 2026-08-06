# SOL Development Roadmap

This roadmap coordinates `sol-engine` and `sol-editor`. Version numbers describe integrated SOL milestones; each repository may ship additional internal builds between them.

## Phase 0 — Foundation (`v0.0.1`)

Goal: establish a reproducible, reversible development baseline.

Engine deliverables:
- SOL runtime package skeleton and version metadata.
- Linux package and launch scripts.
- Lightweight validation workflow.
- E1M1 vertical-slice design contract.

Editor deliverables:
- DoomTools bootstrap for Linux and Windows.
- Common SOL project layout and build entry point.
- Engine launch configuration contract.
- Initial mapping and encounter documentation.

Exit gate:
- Both repositories build or validate from a clean checkout.
- A generated SOL PK3 can be loaded by the engine.
- The editor pipeline can produce a map artifact without committing an IWAD.

## Phase 1 — Playable Graybox (`v0.1.0`)

Goal: produce a complete graybox traversal of the expanded E1M1 vertical slice.

- Establish the arrival, security, processing, reactor, exterior, command, and transition zones.
- Implement critical path, optional loops, locked returns, and readable combat spaces.
- Add first-pass scripted events and environmental story beats.
- Establish baseline enemy counts for low, standard, and horde test profiles.
- Record completion time, navigation failures, deaths, and frame-time spikes.

Exit gate: E1M1 is completable from a clean start with no progression blockers.

## Phase 2 — Story Systems (`v0.2.0`)

Goal: support continuous first-person storytelling without conventional episode interruptions.

- Persistent campaign variables and world-state serialization.
- Scripted environmental sequences that remain player-controlled.
- Dialogue, radio, subtitle, and objective interfaces.
- Map-authored event channels with editor validation.
- Transition-anchor metadata shared by engine and editor.

Exit gate: story events survive save/load and map changes without duplicate execution.

## Phase 3 — Seamless Transition Prototype (`v0.3.0`)

Goal: validate the least disruptive transition architecture before changing core level loading.

Prototype order:
1. Aligned exit/entry anchors with preserved angle, velocity, inventory, and campaign state.
2. No-intermission transition corridors that mask loading.
3. Background preparation and reduced transition stalls where engine architecture permits.
4. True connected-world or streaming work only after profiling proves it necessary and maintainable.

Editor work:
- Paired transition-anchor authoring.
- Geometry alignment checks.
- State-transfer preview and validation.

Exit gate: two test maps feel spatially continuous and recover safely from save/load at either side of the seam.

## Phase 4 — E1M1 Vertical Slice (`v0.5.0`)

Goal: deliver a polished demonstration of SOL's design language.

- Finished traversal, encounter pacing, lighting, soundscape, and environmental narrative.
- Escalating horde encounters with deterministic fallback behavior.
- Original placeholder-replacement asset pass.
- Difficulty, accessibility, and performance profiles.
- Windows and Linux packaged development builds.

Exit gate: external testers can install, launch, complete, and report the slice without developer intervention.

## Phase 5 — Campaign Production Pipeline (`v0.6.0–v0.8.0`)

- Reusable story encounter prefabs.
- Map linting and automated packaging.
- Campaign state inspector.
- Regression maps for transitions, saves, scripts, and large encounters.
- Asset provenance manifest and license validation.

Exit gate: a second connected level can be produced primarily through documented tools rather than one-off engine work.

## Phase 6 — Standalone Product (`v0.9.0`)

- SOL branding and application identity.
- First-run configuration and content discovery.
- Installer/AppImage or equivalent packaging.
- Crash reporting and reproducible diagnostics.
- Removal or replacement of upstream branding where licenses require it.

Exit gate: SOL launches as its own product and contains no unlicensed commercial Doom data.

## Phase 7 — Release (`v1.0.0`)

- Complete campaign content.
- Performance and compatibility certification.
- Save-format migration policy.
- Credits, source distribution, licenses, and corresponding-source compliance.
- Release artifacts and long-term maintenance plan.

## Engineering rules

- Keep upstream synchronization separate from SOL feature commits.
- Prefer data-driven map features before engine modifications.
- Every core-engine change requires a regression case.
- No committed commercial IWAD content.
- Documentation is updated in the same pull request as implementation.