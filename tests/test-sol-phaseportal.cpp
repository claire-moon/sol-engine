#include "playsim/sol_phase_portal_logic.h"

#include <cassert>
#include <initializer_list>

int main()
{
	FSolPhasePortalThresholds thresholds;
	thresholds.ArmDepth = 192.0;
	thresholds.EntryDot = 0.25;
	thresholds.RevealDot = 0.35;

	using State = ESolPhasePortalState;
	// 18: every persisted phase value round-trips to the deterministic state
	// machine rather than relying on a pointer or transient renderer state.
	for (State persisted : {State::DORMANT_LOCAL, State::ENTERED_FORWARD, State::ARMED_INSIDE, State::REVEALED_REMOTE})
		assert(FSolPhasePortalStateMachine::FromStoredValue(uint8_t(persisted)) == persisted);
	assert(FSolPhasePortalStateMachine::FromStoredValue(255) == State::DORMANT_LOCAL);
	State state = State::DORMANT_LOCAL;
	assert(state == State::DORMANT_LOCAL);                                      // 1: initial/local topology
	assert(FSolPhasePortalStateMachine::Advance(state, false, 0, 0, -1, 0, thresholds) == state);
	assert(!FSolPhasePortalStateMachine::IsVisualActive(state, true, true));    // 2: initial visual/traversal gate
	assert(!FSolPhasePortalStateMachine::IsTraversalActive(state, true, true));
	assert(FSolPhasePortalStateMachine::CrossesIntoLocalInterior(-0.1, 0.1));
	assert(FSolPhasePortalStateMachine::CrossesIntoLocalInterior(0.0, 0.1));
	assert(!FSolPhasePortalStateMachine::CrossesIntoLocalInterior(-0.1, 0.0));
	assert(FSolPhasePortalStateMachine::CrossesOutOfLocalInterior(0.1, -0.1));
	assert(!FSolPhasePortalStateMachine::CrossesOutOfLocalInterior(0.1, 0.0));
	assert(FSolPhasePortalStateMachine::IsIntendedOutgoingCrossing(true, false, -1, 1));
	assert(FSolPhasePortalStateMachine::IsIntendedOutgoingCrossing(true, true, 0, 1)); // exact trace intercept
	assert(!FSolPhasePortalStateMachine::IsIntendedOutgoingCrossing(true, true, 4, 1));
	assert(!FSolPhasePortalStateMachine::IsIntendedOutgoingCrossing(true, true, 0, -1));

	// 3: Forward movement and an inward-facing player enter the local room.
	state = FSolPhasePortalStateMachine::Advance(state, true, 0.8, 0.7, 8, 0, thresholds);
	assert(state == State::ENTERED_FORWARD);

	// 5: Retreating before the arm depth removes the pending illusion.
	state = FSolPhasePortalStateMachine::Advance(state, false, 0, 0, -0.5, 0, thresholds);
	assert(state == State::DORMANT_LOCAL);
	state = State::ARMED_INSIDE;
	state = FSolPhasePortalStateMachine::Advance(state, false, 0, 0, -0.5, 0, thresholds);
	assert(state == State::DORMANT_LOCAL);

	// 4: Backing through the threshold while looking outward cannot start a cycle.
	state = FSolPhasePortalStateMachine::Advance(state, true, 0.8, -0.8, 8, 0, thresholds);
	assert(state == State::DORMANT_LOCAL);

	// 6--8: A later genuine entry can arm, reveal, and remain latched through yaw noise.
	state = FSolPhasePortalStateMachine::Advance(state, true, 0.8, 0.8, 8, 0, thresholds);
	assert(state == State::ENTERED_FORWARD);
	state = FSolPhasePortalStateMachine::Advance(state, false, 0, 0, 192, -1, thresholds);
	assert(state == State::ARMED_INSIDE);
	state = FSolPhasePortalStateMachine::Advance(state, false, 0, 0, 192, 0.6, thresholds);
	assert(state == State::REVEALED_REMOTE);
	state = FSolPhasePortalStateMachine::Advance(state, false, 0, 0, 192, -0.9, thresholds);
	assert(state == State::REVEALED_REMOTE);
	assert(FSolPhasePortalStateMachine::IsVisualActive(state, true, true));     // 9: revealed source view
	assert(!FSolPhasePortalStateMachine::IsVisualActive(state, true, false));
	assert(!FSolPhasePortalStateMachine::IsVisualActive(state, false, true));   // 13: destination anchor is local
	assert(FSolPhasePortalStateMachine::IsTraversalActive(state, true, true));  // 10--11: hand to stock transform
	assert(!FSolPhasePortalStateMachine::IsTraversalActive(state, true, false));
	assert(!FSolPhasePortalStateMachine::IsTraversalActive(state, false, true)); // 14: backward anchor probe remains local

	// 12: a successful stock portal
	// transform resets phase atomically before the next frame can observe it.
	const auto saved = uint8_t(state);
	state = State(saved);
	assert(state == State::REVEALED_REMOTE);
	state = FSolPhasePortalStateMachine::StateAfterSuccessfulTraversal();
	assert(state == State::DORMANT_LOCAL);
	assert(!FSolPhasePortalStateMachine::IsVisualActive(state, true, true));

	// 15--17: outward-facing re-entry remains local, but a later deliberate
	// inward-facing pass starts the next independent cycle.
	state = FSolPhasePortalStateMachine::Advance(state, true, 0.8, -0.8, 8, 0, thresholds);
	assert(state == State::DORMANT_LOCAL);
	assert(!FSolPhasePortalStateMachine::IsVisualActive(state, true, true));
	state = FSolPhasePortalStateMachine::Advance(state, true, 0.8, 0.8, 8, 0, thresholds);
	assert(state == State::ENTERED_FORWARD);

	// 19--20: non-source/destination roles cannot become a phase portal; this
	// leaves ordinary linked portal behavior on its existing engine path.
	assert(!FSolPhasePortalStateMachine::IsVisualActive(State::REVEALED_REMOTE, false, true));
	assert(!FSolPhasePortalStateMachine::IsTraversalActive(State::REVEALED_REMOTE, false, true));

	return 0;
}
