# E1M1 Vertical Slice Plan

Working title: **Hangar: Arrival**

This is an expanded interpretation of E1M1's military-base premise. It is not a geometry copy. The level should preserve the immediate readability and forward pressure associated with the original opening while becoming a continuous, story-driven location.

## Experience target

- First completion: 25–40 minutes.
- Critical path remains readable without objective arrows.
- At least three optional spaces reveal what happened before the player arrived.
- Combat escalates from isolated contact to coordinated horde pressure.
- The final corridor establishes a spatially aligned connection to E1M2.
- Story delivery never removes normal player movement for more than a brief mechanical lock.

## Spatial sequence

### 0. Arrival lock

A damaged transfer lift or troop carrier delivers the player into a sealed receiving bay. The player sees the base operating incorrectly before receiving a weapon.

Story evidence:
- Abandoned intake station.
- Repeating security announcement.
- Blood trail entering a restricted service door rather than leaving the facility.

Combat:
- Two visible low-threat enemies establish weapon handling.
- One delayed flank teaches that apparently secure rooms can reopen.

### 1. Hangar floor

A large orientation space with a clearly visible but inaccessible command balcony. The player learns the level's primary visual landmarks here.

Routes:
- Main security checkpoint.
- Maintenance undercroft.
- Optional cargo office containing the first explicit incident record.

### 2. Security spine

A compressed interior route connecting the public base to restricted operations. Windows expose later spaces before the player can reach them.

Story evidence:
- Security shutters closed in the wrong direction.
- Manual barricades facing deeper into the base.
- Conflicting evacuation and containment orders.

Combat:
- Crossfire introduced through windows and elevation.
- First reinforcement event uses doors the player previously passed.

### 3. Processing and maintenance

Interlocking machinery rooms, coolant channels, storage, and worker access tunnels. This zone expands the map laterally and rewards investigation.

Optional loops:
- Restore partial lighting.
- Open a supply cage.
- Vent a contaminated service passage to create a later shortcut.

### 4. Reactor annex

The first major set piece. Failing machinery changes the space while the player remains in control.

Horde profile:
- Wave A: pressure from the visible route.
- Wave B: maintenance access opens behind the player.
- Wave C: elevated attackers force movement across exposed catwalks.
- Recovery window is guaranteed before the final release.

Failure protection:
- Encounter state must survive save/load.
- Doors cannot close permanently while required enemies remain outside the arena.
- A timed fallback opens the exit if an enemy becomes unreachable.

### 5. Exterior breach

A short exterior traversal reveals the scale of the installation and distant evidence of the wider invasion. This is a pacing release, not an empty connector.

Story evidence:
- Damaged transport route.
- Defensive guns aimed toward the base.
- Distant movement suggesting later campaign spaces.

### 6. Command return

The player reaches the balcony seen from the hangar and understands the level's spatial loop. The command systems reveal that the outbreak was detected before the player's arrival but deliberately contained.

Combat:
- Enemies occupy previously safe sightlines.
- The player can use shortcuts unlocked earlier.
- Final encounter combines pursuit with an objective interaction rather than requiring a static arena clear.

### 7. Transition seam

A controlled passage physically aligned with the beginning of E1M2.

Transition contract:
- Record player position relative to a named anchor.
- Preserve view angle, velocity where safe, inventory, health, armor, keys, objectives, and campaign variables.
- Suppress intermission and conventional end-level text.
- E1M2 begins with matching geometry, lighting direction, ambient audio, and door state.
- The first prototype may hide loading through a short traversal or mechanical cycle; true streaming is a later engine decision.

## Enemy-density profiles

- `story`: approximately 70–100 enemies, reduced reinforcement overlap.
- `standard`: approximately 140–190 enemies with full encounter logic.
- `horde`: approximately 260–400 enemies using staged activation and strict active-monster budgets.

Counts are targets, not quotas. Encounters are evaluated by pressure, route use, and frame time.

## Performance budgets

- Target 60 FPS on the Moonbase GTX 1080 test system at the chosen development resolution.
- No more than 80 fully active monsters in ordinary spaces without profiling evidence.
- Horde encounters activate in spatially separated groups.
- Dynamic lights, portals, particles, and thinkers receive explicit per-zone budgets.
- Every major encounter gets a repeatable benchmark save.

## v0.1.0 graybox exit gate

- Complete critical path.
- All required doors recover from save/load.
- No soft locks after sequence breaks tested by the team.
- Story beats have temporary text/audio markers.
- All three density profiles finish within the active-monster budget.
- Transition seam exports the metadata required by the E1M2 prototype.
