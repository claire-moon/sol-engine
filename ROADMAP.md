# SOL Engine-First Development Roadmap

SOL is a free Doom modification and purpose-built UZDoom fork. It requires a
user-owned `DOOM.WAD` or `DOOMU.WAD`; it is not a replacement IWAD or a Doom II
product. Engine development comes first, editor integration follows a frozen
engine SDK, and story/production level work remains parked until both are ready.

Each version below is one gated agent goal. Work uses bounded feature branches,
exact-head checks, squash merges, and post-merge default-branch verification.
The next phase does not begin until the preceding default branch is green.

## Completed foundation

- `v0.0.1`: repository, runtime package, shared editor contract, launch scripts,
  and E1M1 design specification.
- `v0.1.0`: deterministic E1M1 graybox contract, classic Doom progression,
  eighteen-resource wadpack contract 2, and native embedded-resource bundle
  contract 1 using one physical `sol.pk3`.
- `v0.2.0`: story contract 1 and save-persistent runtime state. This machinery
  remains supported, but narrative authoring is parked.

## Product invariants

- The player launches `sol-engine` directly. `sol` remains the setup/status
  cockpit and `sol-edit` remains the authoring entry point.
- The engine support archive is `sol-engine.pk3`; the mandatory adjacent
  gameplay bundle remains the distinct `sol.pk3`.
- Runtime order is engine support, Doom IWAD, mandatory `sol.pk3`, then optional
  user `-file` additions. Extra files, cheats, console warps, or developer
  overrides mark a run `MODIFIED` and disable progression/record writes.
- SOL owns separate configuration, save, cache, log, and profile namespaces. It
  never silently adopts a UZDoom user profile.
- OpenGL and Vulkan are the supported renderers. Software rendering remains an
  internal diagnostic build path but is hidden and unsupported.
- All player-facing presentation uses a centered 4:3 canvas with side pillars.
- Hard map loads remain intentional. SOL does not use seamless map transfer.
- Story contract 1 stays intact and empty content stays valid while story work
  is parked.
- Complete third-party bundles remain local-only until asset-level
  redistribution permission is documented. Free/noncommercial distribution is
  not a substitute for permission.

## Completed — `v0.3.0`: SOL engine identity and native boot

Goal: make SOL a distinctly named engine that automatically boots its mandatory
bundle without wrapper-supplied `-file sol.pk3`.

- Rename executable, support archive, build/package identity, application ID,
  window titles, crash metadata, desktop files, and user-data paths to SOL.
- Add fresh `sol-engine.ini`, SOL save/profile paths, and first-run Doom IWAD
  discovery with a SOL-branded picker when discovery fails.
- Accept Doom and Ultimate Doom in the product launcher and reject Doom II.
- Validate and mount adjacent `sol.pk3` after the IWAD and before optional files.
- Preserve broad mod support after SOL content, with deterministic `MODIFIED`
  state and progression-write suppression.
- Establish a documented curated intake path for selected upstream UZDoom fixes.

Exit gate: clean Windows and Linux installations launch through `sol-engine`,
never require `-file sol.pk3`, and do not read or write UZDoom user state.

## Active — `v0.4.0`: bundle authority and canonical defaults

Goal: make the engine repository authoritative for resource locking, bundle
construction, provenance, and the reproducible gameplay configuration.

- Move the wadpack manifest/importer/locker/builder from editor ownership.
- Introduce bundle contract 2 with explicit `active`, `retired`, `reserved`,
  `runtime`, and `content` slot states.
- Introduce wadpack contract 3: retire/unmount slot 11, preserve slots 12–18,
  reserve/unmount slots 19–20, and place SOL runtime/content at 21–22.
- Introduce `SOLDEFAULTS.json` contract 1 and import only approved renderer,
  mod, audio, HUD, and gameplay values from the development profile.
- Add Reset to SOL Defaults. Never import personal paths, history, bindings, or
  saves.
- Keep upstream archives intact and hash-locked while SOL-owned overlays load
  after them. Keep `THIRD_PARTY.md` embedded and fail public packaging closed
  when rights are unresolved.

Exit gate: locked sources produce reproducible manifests and equivalent bundles
on clean machines, with retired/reserved slots never mounted.

## `v0.5.0`: front end, display, audio baseline, and HUD shell

Goal: replace the inherited player-facing shell with SOL presentation.

- Build an original ZScript/MENUDEF title screen with static replaceable art and
  only START, OPTIONS, and QUIT. START opens the unlocked Chapter selector.
- Curate CONTROLS, DISPLAY, AUDIO, and GAMEPLAY menus; place credits/about under
  options and hide inherited/mod/debug menus outside developer mode.
- Add exact `FRAMERATE` values: Classic (default, `cl_capfps=1`, VSync on) and
  Modern (`cl_capfps=0`, VSync on, no explicit cap). Hide raw cap/VSync controls.
- Fix normal audio mixing at 8000 Hz and expose overrides only in developer mode.
- Enforce the centered 4:3 canvas for gameplay, menus, HUD, transitions, and
  cinematics.
- Retain WW Alpha HUD and add authored whole-cockpit bob/strafe/turn/landing/
  damage motion without distorting the central world view.
- Replace pause flow with RESUME, OPTIONS, ABANDON CHAPTER, and QUIT SOL. Remove
  normal Continue/Save/Load/difficulty surfaces.

Exit gate: OpenGL and Vulkan match the approved 4:3 presentation and exact
framerate/audio defaults on a fresh profile.

## `v0.6.0`: chapter runtime and permadeath

Goal: implement four data-defined Chapters with four core maps and optional M9
secret maps before content depends on them.

- Add `SOLCAMPAIGN.json` contract 1 for chapters, routes, seams, unlocks, and
  chapter completion.
- Lock Chapters 2–4 until the preceding chapter is cleared; use one modified
  Ultra-Violence-derived ruleset with no difficulty selector.
- Keep a run only in memory across hard loads. Quit, crash, abandon, or
  unprotected death forfeits it; no mid-Chapter disk save/resume is available.
- Permit at most one held Soulsphere extra life. Consume it automatically to
  restore the current map-entry snapshot; additional Soulspheres give health.
  Death without one clears the run and returns to title.
- Unlock automap, flashlight, laser sight, and targeting through E1M1–E1M4.
  These reset with a failed Chapter 1 run and become persistent after its clear.
- Return secret maps to the next unfinished core map. Finish each chapter with a
  stat-free completion presentation, persistent unlock, and return to title.
- Keep counters internally but remove player-facing kills/items/secrets/time.

Exit gate: deterministic tests cover every death, Soulsphere, secret route,
travel, quit/crash, modified-run, and chapter-clear state.

## `v0.7.0`: custom UV and Final Custom Doom ownership

Goal: reproduce the approved Final Custom Doom baseline through SOL-owned data
and code before retiring slot 9.

- Baseline: weapon damage 2x, incoming damage 4x, enemy speed 2x, player speed
  0.75x, jump 1.75x, start health/armor 100, max health 200, permanent Strength,
  double firing speed, and permanent Iron Feet.
- Use DeHackEd/BEX/MBF21 where natural and ZScript/native C++ for movement,
  global multipliers, powerups, or lifecycle behavior.
- Retire Final Custom Doom in place only after deterministic parity maps pass.

Exit gate: measurements verify every baseline value and representative combat
behavior.

## `v0.8.0`: survival gameplay, soundscape, and resource integration

Goal: establish the survival-horror interaction layer around the locked stack.

- Add sprint/stamina and the left-HUD meter; integrate flashlight, laser, and
  targeting with campaign unlocks.
- Add `SOLAUDIO.json` contract 1 and a stable sparse cue API for linedef/scripted
  music intercuts, fades, stops, footsteps, landings, and powerup treatments.
  Do not start continuous level music automatically.
- Layer SOL ambience after Universal Ambience and Ambient Decorations.
- Establish SOL gore/dismemberment interfaces around NashGore and voxel gore.
- Keep PSX sound effects in slot 12 as a local-development placeholder and
  replace them in place with user-supplied SOL sounds before public bundling.
- Independently audit all other audio-bearing resources; replacing PlayStation
  audio does not resolve their rights.

Exit gate: every capability works through campaign state, HUD/audio feedback,
modified-run policy, and both hardware renderers.

## `v0.9.0`: signature sky simulation

Goal: replace inherited skies with a deterministic C++/shader subsystem.

- Add `SOLSKY.json` contract 1 with versioned Chapter presets and per-map
  overrides.
- Support particle star fields, scaled planets, layered parallax, animated
  atmospheres/weather, and intense Chapter 4 kaleidoscopic effects.
- Use one deterministic simulation for OpenGL and Vulkan. Permit truecolor sky
  effects while indexed gameplay art follows the SOL palette.
- Preserve the authored result on supported hardware; provide no simplified
  software-renderer substitute.

Exit gate: fixed-seed captures and behavior agree across runs and renderers.

## `v0.10.0`: connected hard-load transitions

Goal: make separate Doom maps feel physically connected without seamless travel.

- Define matching exit/entry seam IDs and validation.
- Carry approved inventory, capabilities, and in-memory run state across hard
  loads using a brief fade/loading mask and no statistics/intermission screen.
- Diagnose mismatched geometry, routing, or content contracts.

Exit gate: core, secret, restart, and chapter-ending routes preserve exactly the
intended state without map leakage.

## `v0.11.0`: legacy hardware optimization

Goal: target a 64-bit 2012-era OpenGL 3.3-class machine without changing SOL's
intended appearance.

- Target roughly Intel HD 4000/GTX 600-class hardware with 4 GB system memory.
- Target 60 FPS Modern mode at 1280x720 output using the canonical Vanilla
  Essence low-resolution presentation.
- Add deterministic interior, exterior-sky, gore, particle, lighting, and HUD
  benchmark scenes; record CPU/GPU frame time and memory.
- Profile/optimize or natively replace costly voxel, lighting, culling, gore,
  sky, HUD, audio, and mounting paths where justified.

Exit gate: reproducible reports pass on representative physical legacy hardware;
the minimum-spec claim remains provisional until that physical test exists.

## `v0.12.0`: engine beta, SDK, and packaging

Goal: freeze a stable engine surface for editor integration.

- Publish SOL SDK contract 1 with versioned executable interface, schemas,
  validators, support resources, metadata, diagnostics, and playtest contract.
- Harden missing/corrupt IWAD, bundle mismatch, config migration, crash reporting,
  and modified-run diagnostics.
- Ship Windows and Linux packages; keep macOS best-effort.
- Separate publishable engine/source/SDK artifacts from the complete `sol.pk3`,
  which remains local-only until every bundled asset has documented rights.
- Define post-beta compatibility and curated-upstream intake policy.

Exit gate: clean install, upgrade, rollback, corruption, mismatch, and SDK
compatibility suites pass.

## Editor-led milestones after engine beta

- `v0.13.0`: canonical 256-color SOL palette, derived translations/colormaps,
  `sol-palette`, and `sol-voxel` CLI/GUI with deterministic KVX export, metadata,
  editing, batch operations, and live engine preview.
- `v0.14.0`: package/discover the versioned SDK and integrate it into
  `sol-editor` without a sibling source dependency.
- `v0.15.0`: visual chapter, transition, sky, audio-cue, unlock, gameplay,
  palette, voxel, validation, packaging, benchmark, and playtest authoring UX.

Only after `v0.15.0` do production graphical treatment, custom sound replacement,
story authoring, and level design resume. Explore/JP mode and an invisible sanity
system remain research backlog items.
