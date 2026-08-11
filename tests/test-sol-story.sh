#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
entry="$root/sol/game/ZSCRIPT"
ids="$root/sol/game/zscript/sol/story_ids.zs"
state="$root/sol/game/zscript/sol/story_state.zs"
bootstrap="$root/sol/game/zscript/sol/bootstrap.zs"
mapinfo="$root/sol/game/MAPINFO"
wadpack="$root/sol/wadpack.json"
level_travel="$root/src/g_level.cpp"
p_map="$root/src/playsim/p_map.cpp"
doomplayer="$root/wadsrc/static/zscript/actors/doom/doomplayer.zs"

grep -Fx '#include "zscript/sol/story_ids.zs"' "$entry" >/dev/null
grep -Fx '#include "zscript/sol/story_state.zs"' "$entry" >/dev/null
grep -Fx '#include "zscript/sol/bootstrap.zs"' "$entry" >/dev/null
! grep -F 'portal_guard.zs' "$entry" >/dev/null
test ! -e "$root/sol/game/zscript/sol/portal_guard.zs"
! grep -R -F 'class SolPlayer' "$root/sol/game" >/dev/null
! grep -R -F 'Player.StartItem' "$root/sol/game" >/dev/null
grep -F 'const Contract = 1;' "$ids" >/dev/null
grep -F 'const MinId = 1;' "$ids" >/dev/null
grep -F 'const MaxId = 65535;' "$ids" >/dev/null
grep -F 'Array<int> FiredEvents;' "$state" >/dev/null
grep -F 'Array<int> CompletedObjectives;' "$state" >/dev/null
grep -F 'Array<int> SeenSubtitles;' "$state" >/dev/null
grep -F 'Array<int> HeardRadio;' "$state" >/dev/null
grep -F 'int CurrentObjective;' "$state" >/dev/null
! grep -Eq '^[[:space:]]*transient[[:space:]]+(int|Array<int>)[[:space:]]+(ContractVersion|CurrentObjective|FiredEvents|CompletedObjectives|SeenSubtitles|HeardRadio)' "$state"
grep -F 'Player.StartItem "Pistol";' "$doomplayer" >/dev/null
grep -F 'Player.StartItem "Fist";' "$doomplayer" >/dev/null
grep -F 'Player.StartItem "Clip", 50;' "$doomplayer" >/dev/null
grep -F 'Player.WeaponSlot 1, "Fist", "Chainsaw";' "$doomplayer" >/dev/null
grep -F 'Player.WeaponSlot 2, "Pistol";' "$doomplayer" >/dev/null
python3 - "$wadpack" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as handle:
    data = json.load(handle)

slots = {entry["slot"]: entry for entry in data["slots"]}
angled = slots[6]
assert angled["state"] == "active"
assert angled["id"] == "angled-doom-lite"
assert angled["required"] is True
assert angled["runtime_name"] == "06-angled-doom-lite-1.2.1.pk3"
PY
! grep -F 'sollocaltraversal' "$p_map" >/dev/null
! grep -F 'ld->args[0] == 9001 || ld->args[0] == 9002' "$p_map" >/dev/null
grep -F 'AddEventHandlers = "SolBootstrap"' "$mapinfo" >/dev/null
! grep -F 'PlayerClasses' "$mapinfo" >/dev/null
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
