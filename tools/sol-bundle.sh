#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
editor_root=${SOL_EDITOR_ROOT:-"$root/../sol-editor"}
bundler="$editor_root/tools/sol-bundle.sh"

if [[ ! -f $bundler ]]; then
    printf 'Sibling SOL editor bundler not found: %s\n' "$bundler" >&2
    exit 1
fi

export SOL_ENGINE_ROOT="$root"
export SOL_EDITOR_ROOT="$editor_root"
exec bash "$bundler" "$@"
