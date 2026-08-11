# SOL! geometry contract 1

SOL! geometry contract 1 makes impossible space a supported gameplay primitive
rather than a map-specific teleport effect.

## Contract

The contract keeps the engine's native linked line-portal machinery as the
conventional non-Euclidean primitive. A linked pair is reciprocal, interactive,
passable, preserves actor/projectile traversal, and translates world position
between two physically remote linedefs while rendering through the destination.
The paired lines must have compatible dimensions, opposite-facing orientation,
and real two-sided space behind each threshold.

For UDMF test content the canonical primitive is `Line_SetPortal` (`special =
156`) with portal type `PORTT_LINKED` (`arg2 = 3`). `arg0` names the destination
linedef ID. The destination must point back to the source through its own linked
portal definition.

SOL! also provides an opt-in phase portal for authored impossible rooms. It is
not a special case for TESTMAP IDs and does not modify global portal flags. A
phase source uses `PORTT_TELEPORT` (`arg2 = 1`) and retained UDMF properties:
`user_sol_phase_role`, `user_sol_phase_group`, `user_sol_phase_inside_side`,
`user_sol_phase_arm_depth`, `user_sol_phase_entry_dot`, and
`user_sol_phase_reveal_dot`. Its destination is a `user_sol_phase_role =
"destination"` anchor with its normal linedef ID but no `Line_SetPortal`
special or reverse destination ID, preserving ordinary two-sided local crossing.

The inherited teleport traversal is side-0 to side-1, so a valid phase source
declares its room interior as `user_sol_phase_inside_side = 0`. Authors choose
that orientation by flipping the source linedef; the explicit property makes
the authored intent and state-machine sign unambiguous rather than relying on
coordinates or TESTMAP-specific IDs. Keep the local approach, full doorway
span, and route through the arm depth clear of solid props: dormant collision is
intentionally ordinary local topology, so blocked movement must never disguise
the direction-sensitive phase predicate.

The engine holds `DORMANT_LOCAL`, `ENTERED_FORWARD`, `ARMED_INSIDE`, and
`REVEALED_REMOTE` state per player and phase group. The source remains a normal
local two-sided doorway until the player crosses into its declared inside side
with both actual movement and canonical player-facing dot products above the
authored entry threshold. Reaching arm depth, then looking outward across the
reveal threshold, latches the remote portal. The successful revealed
inside-to-outside teleport resets that player to `DORMANT_LOCAL` in the same
gameplay tic. The player pawn and player-fired hitscan/line traces use the
revealed source; non-player movement (including player-owned projectiles),
unowned traces, sound, and AI sight stay local in v0.4. This deterministic
local policy avoids an undefined global topology in multiplayer.

`sol_phaseportal_debug` is off by default. Level 1 reports initialization and
state transitions with phase/group and directional values. Use the
`sol_phaseportal_status` console command for an on-demand player/group report
of signed depth, outward view dot, visual activity, traversal readiness, and
the destination anchor's always-local role; level 3 additionally logs actual
source traversal predicate decisions without mutating state.

## TESTMAP demonstrations

E1M1 is presented to the player as `TESTMAP`. It contains a stateful phase
portal demonstration and a separate reciprocal linked portal demonstration.

The phase source is linedef 9001, the actual entrance to a physically local
dead-end Phase Room. Linedef 9002 is its remote destination-only anchor. The
room stays local on entry and only reveals 9002 after a forward-facing entry,
interior arm depth, and an outward turn. Immediately after the source teleport,
9001 is dormant again, so probing backward over 9002 is wholly local.

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
