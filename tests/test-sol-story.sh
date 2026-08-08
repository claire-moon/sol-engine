#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
entry="$root/sol/game/ZSCRIPT"
ids="$root/sol/game/zscript/sol/story_ids.zs"
state="$root/sol/game/zscript/sol/story_state.zs"

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
