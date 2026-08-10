# SOL! geometry contract 1

SOL! geometry contract 1 makes impossible space a supported gameplay primitive
rather than a map-specific visual trick.

## Contract

The contract uses the engine's native linked line-portal machinery as the first
stable SOL! non-Euclidean primitive. A linked pair is reciprocal, interactive,
passable, preserves actor/projectile traversal, and translates world position
between two physically remote linedefs while rendering through the destination.
The paired lines must have compatible dimensions, opposite-facing orientation,
and real two-sided space behind each threshold.

For UDMF test content the canonical primitive is `Line_SetPortal` (`special =
156`) with portal type `PORTT_LINKED` (`arg2 = 3`). `arg0` names the destination
linedef ID. The destination must point back to the source through its own linked
portal definition. SOL! validates this reciprocal shape in its deterministic
TESTMAP fixture.

## TESTMAP demonstration

E1M1 is presented to the player as `TESTMAP`. It contains one reciprocal linked
portal pair using linedef IDs 9001 and 9002. The two thresholds are physically
separated in the editor layout, but a forward crossing places the player at the
remote threshold with continuous rendering and movement. The result is a
deliberately impossible adjacency: the apparent room connection does not match
Euclidean map space.

TESTMAP adds a player-facing traversal policy to this demonstration pair. When
the player's pending XY movement has a forward component relative to the current
view direction, the engine keeps the normal linked-portal displacement and
portal interpolation. When the player is looking away from the threshold and
moves backward through it, the engine suppresses the linked displacement and
portal interpolation. The ordinary two-sided linedef then behaves as local map
geometry, so the player walks into the physically adjacent room without a
teleport transition. The policy is specific to TESTMAP destination IDs 9001 and
9002 and does not change the engine's ordinary linked-portal semantics.

TESTMAP contains no monsters. Its purpose in v0.4 is deterministic validation of
geometry, rendering, material, lighting, ambience, prop, weapon, and resource
contracts without combat obscuring portal behavior.

## Future impossible-space work

Geometry contract 1 is the foundation for later episode authoring. Later
contracts may layer portal graphs, recursive views, scale/perspective staging,
conditional topology, and authored transition logic to create spaces in the
spirit of impossible-room and forced-perspective games. Those effects must build
on explicit SOL! contracts and deterministic tests rather than hidden map hacks.
