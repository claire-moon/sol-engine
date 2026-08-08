#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
editor_root=${SOL_EDITOR_ROOT:-"$root/../sol-editor"}
bundler="$editor_root/tools/sol-bundle.sh"
target="$root/build/sol/sol.pk3"
runtime_packager="$root/tools/sol-runtime-package.sh"

if [[ -x $bundler ]]; then
    export SOL_ENGINE_ROOT="$root"
    export SOL_EDITOR_ROOT="$editor_root"
    if bundle=$(SOL_BUNDLE_NO_SETUP=1 bash "$bundler" 2>/dev/null); then
        if [[ -f $bundle ]]; then
            test -f "$target" || {
                mkdir -p "$(dirname "$target")"
                cp -f "$bundle" "$target"
            }
            printf '%s\n' "$target"
            exit 0
        fi
    fi
fi

# First-run workspace setup happens before the local third-party pack is
# complete. Preserve that bootstrap path by emitting only the SOL-owned runtime
# component until the self-contained bundle can be constructed.
printf 'SOL final bundle unavailable; emitting runtime component only.\n' >&2
exec bash "$runtime_packager"
