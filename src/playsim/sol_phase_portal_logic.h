#pragma once

#include <cstdint>

// Dependency-free deterministic transition kernel for SOL phase portals.
// It is intentionally kept separate from renderer and map ownership code so
// the behavioral regression test can exercise the exact production logic.
enum class ESolPhasePortalState : uint8_t
{
	DORMANT_LOCAL,
	ENTERED_FORWARD,
	ARMED_INSIDE,
	REVEALED_REMOTE,
};

struct FSolPhasePortalThresholds
{
	double ArmDepth = 192.0;
	double EntryDot = 0.25;
	double RevealDot = 0.35;
};

class FSolPhasePortalStateMachine
{
public:
	static bool IsVisualActive(ESolPhasePortalState state, bool isSource, bool viewIsInside)
	{
		return state == ESolPhasePortalState::REVEALED_REMOTE && isSource && viewIsInside;
	}

	static bool IsTraversalActive(ESolPhasePortalState state, bool isSource, bool crossesInsideToOutside)
	{
		return state == ESolPhasePortalState::REVEALED_REMOTE && isSource && crossesInsideToOutside;
	}

	static ESolPhasePortalState StateAfterSuccessfulTraversal()
	{
		return ESolPhasePortalState::DORMANT_LOCAL;
	}

	static ESolPhasePortalState Advance(ESolPhasePortalState state, bool crossedForward,
		double movementDot, double facingDot, double signedDepth, double revealDot,
		const FSolPhasePortalThresholds &thresholds)
	{
		switch (state)
		{
		case ESolPhasePortalState::DORMANT_LOCAL:
			if (crossedForward && movementDot >= thresholds.EntryDot && facingDot >= thresholds.EntryDot)
				return ESolPhasePortalState::ENTERED_FORWARD;
			break;
		case ESolPhasePortalState::ENTERED_FORWARD:
			if (signedDepth < 0.0)
				return ESolPhasePortalState::DORMANT_LOCAL;
			if (signedDepth >= thresholds.ArmDepth)
				return ESolPhasePortalState::ARMED_INSIDE;
			break;
		case ESolPhasePortalState::ARMED_INSIDE:
			if (signedDepth < 0.0)
				return ESolPhasePortalState::DORMANT_LOCAL;
			if (revealDot >= thresholds.RevealDot)
				return ESolPhasePortalState::REVEALED_REMOTE;
			break;
		case ESolPhasePortalState::REVEALED_REMOTE:
			break;
		}
		return state;
	}
};
