#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
entry="$root/sol/game/ZSCRIPT"
ids="$root/sol/game/zscript/sol/story_ids.zs"
state="$root/sol/game/zscript/sol/story_state.zs"
portal_guard="$root/sol/game/zscript/sol/portal_guard.zs"
bootstrap="$root/sol/game/zscript/sol/bootstrap.zs"
mapinfo="$root/sol/game/MAPINFO"
level_travel="$root/src/g_level.cpp"
p_map="$root/src/playsim/p_map.cpp"
doomplayer="$root/wadsrc/static/zscript/actors/doom/doomplayer.zs"
thingdef_properties="$root/src/scripting/thingdef_properties.cpp"
thingdef_parse="$root/src/scripting/decorate/thingdef_parse.cpp"

grep -Fx '#include "zscript/sol/story_ids.zs"' "$entry" >/dev/null
grep -Fx '#include "zscript/sol/story_state.zs"' "$entry" >/dev/null
grep -Fx '#include "zscript/sol/portal_guard.zs"' "$entry" >/dev/null
grep -F 'const Contract = 1;' "$ids" >/dev/null
grep -F 'const MinId = 1;' "$ids" >/dev/null
grep -F 'const MaxId = 65535;' "$ids" >/dev/null
grep -F 'Array<int> FiredEvents;' "$state" >/dev/null
grep -F 'Array<int> CompletedObjectives;' "$state" >/dev/null
grep -F 'Array<int> SeenSubtitles;' "$state" >/dev/null
grep -F 'Array<int> HeardRadio;' "$state" >/dev/null
grep -F 'int CurrentObjective;' "$state" >/dev/null
! grep -Eq '^[[:space:]]*transient[[:space:]]+(int|Array<int>)[[:space:]]+(ContractVersion|CurrentObjective|FiredEvents|CompletedObjectives|SeenSubtitles|HeardRadio)' "$state"
grep -F 'class SolPlayer : DoomPlayer' "$portal_guard" >/dev/null
grep -F 'Player.StartItem "Fist";' "$portal_guard" >/dev/null
grep -F 'Player.StartItem "Clip", 50;' "$portal_guard" >/dev/null
! grep -F 'Player.StartItem "Pistol";' "$portal_guard" >/dev/null
! grep -F 'CanCrossLine' "$portal_guard" >/dev/null
grep -F 'Player.StartItem "Pistol";' "$doomplayer" >/dev/null
grep -F 'if (!bag.DropItemSet)' "$thingdef_properties" >/dev/null
grep -F 'bag.DropItemList = NULL;' "$thingdef_properties" >/dev/null
grep -F 'bag.Info->SetDropItems(bag.DropItemList);' "$thingdef_parse" >/dev/null
grep -F 'const DVector2 solmove = tm.pos.XY() - thing->Pos().XY();' "$p_map" >/dev/null
grep -F 'ld->args[2] == PORTT_LINKED' "$p_map" >/dev/null
grep -F '(ld->args[0] == 9001 || ld->args[0] == 9002)' "$p_map" >/dev/null
grep -F '(solmove | thing->Angles.Yaw.ToVector()) < 0.0' "$p_map" >/dev/null
grep -F 'if (sollocaltraversal)' "$p_map" >/dev/null
grep -F 'PlayerClasses = "SolPlayer"' "$mapinfo" >/dev/null
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
