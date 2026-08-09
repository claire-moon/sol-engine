# Contributing to SOL Engine

SOL Engine is an engine-first standalone product derived from UZDoom. Before
opening a change, read [ROADMAP.md](ROADMAP.md), [SOL.md](SOL.md), and the
[upstream intake policy](docs/sol/upstream-intake.md). Changes should preserve
the active phase boundaries and the native `sol.pk3` runtime contract.

## Issues and proposals

- Keep unrelated problems in separate reports.
- Include the SOL Engine version, operating system, hardware, logs, exact
  reproduction steps, and whether the run was marked `MODIFIED`.
- Test against the current `trunk` build when practical.
- Do not report general UZDoom issues here unless they reproduce in SOL Engine
  or the proposal explains why SOL should carry a deliberate divergence.

## Pull requests

- Base engine work on `trunk` and keep each pull request focused.
- Preserve inherited authorship, comments, copyright notices, and license
  history.
- New engine code must be GPL-3.0-or-later or under a compatible license.
- Run the relevant SOL validation and platform build checks.
- Do not bundle a Doom IWAD or the local-only complete `sol.pk3`.
- Document intentional divergence from UZDoom and identify any upstream commit
  imported through the curated intake process.

## Assets and third-party code

Contributors must have the right to submit every asset and code fragment they
add. Record the creator, source, license, modifications, and required notices.
Attribution alone is not redistribution permission. Assets without confirmed
public redistribution terms must remain outside public packages.

The approved SOL identity must not be redrawn, recolored, or replaced without a
recorded project decision. Voxel and other graphical treatments must preserve
their source provenance as they are converted into SOL-owned work.

## Review standard

Reviews prioritize deterministic behavior, standalone identity, old-hardware
regression risk, save/progression integrity, licensing, and compatibility with
the matching `sol-editor` contract. Passing CI is required but does not replace
runtime testing against the canonical local bundle.
