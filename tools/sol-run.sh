#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
editor_root=${SOL_EDITOR_ROOT:-"$root/../sol-editor"}
editor_launcher="$editor_root/tools/sol-test.sh"

if [[ ! -x $editor_launcher ]]; then
    printf 'Sibling SOL editor launcher not found: %s\n' "$editor_launcher" >&2
    exit 1
fi

# The editor-side launcher is the single source of truth for IWAD selection,
# locked wadpack order, current engine runtime, and current map package.
export SOL_ENGINE_ROOT="$root"
export SOL_EDITOR_ROOT="$editor_root"
exec "$editor_launcher" "$@"
