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
	static constexpr double ExactInterceptEpsilon = 1.e-6;

	// A local phase doorway only changes state after the player's committed
	// movement crosses its threshold.  Keep the endpoint convention here so
	// both the playsim integration and the deterministic regression test agree
	// about a movement beginning exactly on the threshold.
	static bool CrossesIntoLocalInterior(double oldSignedDepth, double newSignedDepth)
	{
		return oldSignedDepth <= ExactInterceptEpsilon && newSignedDepth > ExactInterceptEpsilon;
	}

	static bool CrossesOutOfLocalInterior(double oldSignedDepth, double newSignedDepth)
	{
		return oldSignedDepth >= -ExactInterceptEpsilon && newSignedDepth < -ExactInterceptEpsilon;
	}

	static ESolPhasePortalState FromStoredValue(uint8_t value)
	{
		switch (value)
		{
		case uint8_t(ESolPhasePortalState::DORMANT_LOCAL): return ESolPhasePortalState::DORMANT_LOCAL;
		case uint8_t(ESolPhasePortalState::ENTERED_FORWARD): return ESolPhasePortalState::ENTERED_FORWARD;
		case uint8_t(ESolPhasePortalState::ARMED_INSIDE): return ESolPhasePortalState::ARMED_INSIDE;
		case uint8_t(ESolPhasePortalState::REVEALED_REMOTE): return ESolPhasePortalState::REVEALED_REMOTE;
		default: return ESolPhasePortalState::DORMANT_LOCAL;
		}
	}

	static bool IsVisualActive(ESolPhasePortalState state, bool isSource, bool viewIsInside)
	{
		return state == ESolPhasePortalState::REVEALED_REMOTE && isSource && viewIsInside;
	}

	static bool IsTraversalActive(ESolPhasePortalState state, bool isSource, bool crossesInsideToOutside)
	{
		return state == ESolPhasePortalState::REVEALED_REMOTE && isSource && crossesInsideToOutside;
	}

	// Actors hand us an endpoint beyond the line, but generic traces hand us
	// their exact intercept. The latter is geometrically on side 0, so accept
	// it only if the ray was outward and reached the threshold itself.
	static bool IsIntendedOutgoingCrossing(bool oldIsInside, bool newIsInside,
		double signedNewDepth, double outwardMovementDot)
	{
		return oldIsInside && (!newIsInside ||
			(signedNewDepth <= ExactInterceptEpsilon && outwardMovementDot > ExactInterceptEpsilon));
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
		default:
			return ESolPhasePortalState::DORMANT_LOCAL;
		}
		return state;
	}
};
