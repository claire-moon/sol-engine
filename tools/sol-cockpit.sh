#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
editor_root=${SOL_EDITOR_ROOT:-"$root/../sol-editor"}
cockpit="$editor_root/tools/sol-cockpit.sh"
if [[ ! -f $cockpit ]]; then
    printf 'Sibling sol-editor cockpit not found: %s\n' "$cockpit" >&2
    exit 1
fi
exec bash "$cockpit" --engine-root "$root" "$@"
