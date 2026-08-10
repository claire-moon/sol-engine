# SOL! geometry contract 1

SOL! geometry contract 1 makes impossible space a supported gameplay primitive
rather than a map-specific teleport effect.

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
portal definition.

SOL! does not change linked-portal traversal according to player view direction,
movement direction, or map-specific linedef IDs. Portal rendering and movement
remain engine primitives; concealment and reveal behavior belong to authored map
geometry.

## TESTMAP demonstrations

E1M1 is presented to the player as `TESTMAP`. It contains two reciprocal linked
portal demonstrations.

The illusion pair uses linedef IDs 9001 and 9002. Its local chamber has an
ordinary physical entrance on a side wall, while the portal threshold is placed
on a different wall. A player can therefore enter the chamber normally, turn to
look back toward the physical entrance, and walk backward through the portal.
The remote chamber uses the same material and dimensional language, and its
ordinary exit is arranged away from the portal sightline. Looking back after
leaving the remote chamber does not put the original physical entrance directly
behind the portal threshold. The impossible-room effect is produced by layout,
matching surfaces, and occlusion rather than conditional teleport code.

The portal-lab pair uses linedef IDs 9011 and 9012. It is intentionally less
concealed so rendering through a linked portal can be inspected directly. The
lab is separated from the main test route by an authored `Door_Open` gate and is
decorated as an intentional test chamber rather than exposing a bare portal in
the middle of the general map.

TESTMAP contains no monsters. Its purpose in v0.4 is deterministic validation of
geometry, rendering, material, lighting, ambience, prop, weapon, and resource
contracts without combat obscuring portal behavior.

## Future impossible-space work

Geometry contract 1 is the foundation for later episode authoring. Later
contracts may layer portal graphs, recursive views, scale/perspective staging,
conditional topology, and authored transition logic to create spaces in the
spirit of impossible-room and forced-perspective games. Those effects must build
on explicit SOL! contracts and deterministic tests rather than hidden engine
special cases.
