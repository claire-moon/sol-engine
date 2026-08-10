#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
target="$root/build/sol/sol.pk3"
runtime_packager="$root/tools/sol-runtime-package.sh"

if bundle=$(SOL_BUNDLE_NO_SETUP=1 bash "$root/tools/sol-bundle.sh" 2>/dev/null); then
    if [[ -f $bundle ]]; then
        if [[ $(realpath -m "$bundle") != $(realpath -m "$target") ]]; then
            mkdir -p "$(dirname "$target")"
            cp -f "$bundle" "$target"
        fi
        printf '%s\n' "$target"
        exit 0
    fi
fi

printf 'SOL final bundle unavailable; emitting runtime component only.\n' >&2
exec bash "$runtime_packager"
