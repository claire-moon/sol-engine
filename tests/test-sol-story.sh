#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
entry="$root/sol/game/ZSCRIPT"
ids="$root/sol/game/zscript/sol/story_ids.zs"
state="$root/sol/game/zscript/sol/story_state.zs"
bootstrap="$root/sol/game/zscript/sol/bootstrap.zs"
level_travel="$root/src/g_level.cpp"

grep -Fx '#include "zscript/sol/story_ids.zs"' "$entry" >/dev/null
grep -Fx '#include "zscript/sol/story_state.zs"' "$entry" >/dev/null
grep -F 'const Contract = 1;' "$ids" >/dev/null
grep -F 'const MinId = 1;' "$ids" >/dev/null
grep -F 'const MaxId = 65535;' "$ids" >/dev/null
grep -F 'Array<int> FiredEvents;' "$state" >/dev/null
grep -F 'Array<int> CompletedObjectives;' "$state" >/dev/null
grep -F 'Array<int> SeenSubtitles;' "$state" >/dev/null
grep -F 'Array<int> HeardRadio;' "$state" >/dev/null
grep -F 'int CurrentObjective;' "$state" >/dev/null
! grep -Eq '^[[:space:]]*transient[[:space:]]+(int|Array<int>)[[:space:]]+(ContractVersion|CurrentObjective|FiredEvents|CompletedObjectives|SeenSubtitles|HeardRadio)' "$state"
grep -F 'void EnsureStoryState(int playerNumber)' "$bootstrap" >/dev/null
grep -F 'pawn.FindInventory(storyType)' "$bootstrap" >/dev/null
grep -F 'pawn.GiveInventoryType(storyType);' "$bootstrap" >/dev/null
grep -F 'override void WorldLoaded(WorldEvent event)' "$bootstrap" >/dev/null
grep -F 'override void PlayerEntered(PlayerEvent event)' "$bootstrap" >/dev/null
grep -F 'override void PlayerSpawned(PlayerEvent event)' "$bootstrap" >/dev/null
# UZDoom moves the live player pawn and recursively moves its inventory actors
# through the travelling-thinker list. SolStoryState therefore crosses ordinary
# level transitions as the same object, preserving its custom member arrays.
grep -F 'AddToTravellingList(Players[i]->mo);' "$level_travel" >/dev/null
grep -F 'for (AActor* inv = mo->Inventory; inv != nullptr; inv = inv->Inventory)' "$level_travel" >/dev/null
grep -F 'AddToTravellingList(inv);' "$level_travel" >/dev/null
