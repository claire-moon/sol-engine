#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
editor_root=${SOL_EDITOR_ROOT:-"$root/../sol-editor"}
bundler="$editor_root/tools/sol-bundle.sh"
target="$root/build/sol/sol.pk3"

if [[ ! -x $bundler ]]; then
    printf 'Sibling SOL editor bundler not found: %s\n' "$bundler" >&2
    exit 1
fi

export SOL_ENGINE_ROOT="$root"
export SOL_EDITOR_ROOT="$editor_root"
bundle=$(bash "$bundler")
if [[ ! -f $bundle ]]; then
    printf 'SOL bundle was not produced: %s\n' "$bundle" >&2
    exit 1
fi
if [[ ! -f $target ]]; then
    mkdir -p "$(dirname "$target")"
    cp -f "$bundle" "$target"
fi
printf '%s\n' "$target"
