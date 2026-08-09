/*
** sol_run_state.h
**
** Deterministic SOL campaign-integrity state.
**
** SPDX-License-Identifier: GPL-3.0-or-later
*/

#pragma once

#include <stdint.h>

enum ESolRunModification : uint32_t
{
	SOLMOD_None          = 0,
	SOLMOD_ExtraFiles    = 1u << 0,
	SOLMOD_Dehacked      = 1u << 1,
	SOLMOD_StartupWarp   = 1u << 2,
	SOLMOD_Cheat         = 1u << 3,
	SOLMOD_ConsoleTravel = 1u << 4,
	SOLMOD_Developer     = 1u << 5,
};

void SOL_ResetRunState();
void SOL_CaptureRunBaseline();
void SOL_RequestNewRunReset();
void SOL_ApplyNewRunReset();
void SOL_MarkRunModified(ESolRunModification reason);
bool SOL_IsRunModified();
uint32_t SOL_GetRunModificationMask();
void SOL_RestoreRunModificationMask(uint32_t mask);

// Every persistent campaign/progression write introduced in later phases must
// pass through this guard. Modified runs may play normally but cannot advance
// authoritative SOL progression.
bool SOL_CanWriteProgression();
bool SOL_AllowProgressionWrite(const char* surface);
