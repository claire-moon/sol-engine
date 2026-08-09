/*
** sol_run_state.cpp
**
** Deterministic SOL campaign-integrity state.
**
** SPDX-License-Identifier: GPL-3.0-or-later
*/

#include "sol_run_state.h"

#include "c_cvars.h"
#include "c_dispatch.h"
#include "printf.h"
#include "zstring.h"

CVAR(Bool, sol_run_modified, false, CVAR_NOSET)
CVAR(String, sol_run_modified_reasons, "", CVAR_NOSET)

static uint32_t SolRunModificationMask;
static uint32_t SolRunBaselineMask;
static bool SolNewRunResetPending;

static FString BuildReasonList(uint32_t mask)
{
	struct ReasonName
	{
		uint32_t Bit;
		const char* Name;
	};
	static const ReasonName names[] = {
		{ SOLMOD_ExtraFiles, "extra-files" },
		{ SOLMOD_Dehacked, "dehacked" },
		{ SOLMOD_StartupWarp, "startup-warp" },
		{ SOLMOD_Cheat, "cheat" },
		{ SOLMOD_ConsoleTravel, "console-travel" },
		{ SOLMOD_Developer, "developer" },
	};

	FString result;
	for (const auto& entry : names)
	{
		if ((mask & entry.Bit) == 0) continue;
		if (result.IsNotEmpty()) result += ",";
		result += entry.Name;
	}
	return result;
}

static void PublishRunState()
{
	FString reasons = BuildReasonList(SolRunModificationMask);
	sol_run_modified->ForceSet(SolRunModificationMask != 0, CVAR_Bool);
	sol_run_modified_reasons->ForceSet(reasons.GetChars(), CVAR_String);
}

void SOL_ResetRunState()
{
	SolRunModificationMask = SOLMOD_None;
	SolRunBaselineMask = SOLMOD_None;
	SolNewRunResetPending = false;
	PublishRunState();
}

void SOL_CaptureRunBaseline()
{
	// Files and startup configuration describe the process itself and cannot
	// become canonical by selecting New Game. A menu-started campaign may,
	// however, discard an earlier warp, cheat, or console-travel attempt.
	SolRunBaselineMask = SolRunModificationMask &
		(SOLMOD_ExtraFiles | SOLMOD_Dehacked | SOLMOD_Developer);
}

void SOL_RequestNewRunReset()
{
	SolNewRunResetPending = true;
}

void SOL_ApplyNewRunReset()
{
	if (!SolNewRunResetPending) return;
	SolNewRunResetPending = false;
	SolRunModificationMask = SolRunBaselineMask;
	PublishRunState();
}

void SOL_MarkRunModified(ESolRunModification reason)
{
	uint32_t oldMask = SolRunModificationMask;
	SolRunModificationMask |= static_cast<uint32_t>(reason);
	if (SolRunModificationMask == oldMask) return;

	PublishRunState();
	Printf(TEXTCOLOR_ORANGE "SOL run is modified (%s). Persistent campaign progression is disabled.\n",
		sol_run_modified_reasons->GetGenericRep(CVAR_String).String);
}

bool SOL_IsRunModified()
{
	return SolRunModificationMask != SOLMOD_None;
}

uint32_t SOL_GetRunModificationMask()
{
	return SolRunModificationMask;
}

void SOL_RestoreRunModificationMask(uint32_t mask)
{
	constexpr uint32_t knownReasons = SOLMOD_ExtraFiles | SOLMOD_Dehacked |
		SOLMOD_StartupWarp | SOLMOD_Cheat | SOLMOD_ConsoleTravel | SOLMOD_Developer;
	uint32_t oldMask = SolRunModificationMask;
	SolRunModificationMask |= mask & knownReasons;
	if (SolRunModificationMask != oldMask) PublishRunState();
}

bool SOL_CanWriteProgression()
{
	return !SOL_IsRunModified();
}

bool SOL_AllowProgressionWrite(const char* surface)
{
	if (SOL_CanWriteProgression()) return true;
	Printf(TEXTCOLOR_ORANGE "SOL did not write %s because this run is modified (%s).\n",
		surface ? surface : "campaign progression",
		sol_run_modified_reasons->GetGenericRep(CVAR_String).String);
	return false;
}

CCMD(sol_run_status)
{
	if (!SOL_IsRunModified())
	{
		Printf("SOL run status: canonical; campaign progression writes are enabled.\n");
	}
	else
	{
		Printf("SOL run status: modified (%s); campaign progression writes are disabled.\n",
			sol_run_modified_reasons->GetGenericRep(CVAR_String).String);
	}
}
