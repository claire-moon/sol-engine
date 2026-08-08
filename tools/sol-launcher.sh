#!/usr/bin/env bash
set -euo pipefail

source_path=${BASH_SOURCE[0]}
while [[ -L $source_path ]]; do
    source_dir=$(cd -P "$(dirname "$source_path")" && pwd)
    source_path=$(readlink "$source_path")
    if [[ $source_path != /* ]]; then
        source_path="$source_dir/$source_path"
    fi
done
launcher_dir=$(cd -P "$(dirname "$source_path")" && pwd)

find_engine() {
    local candidate
    for candidate in \
        "${SOL_ENGINE:-}" \
        "$launcher_dir/uzdoom" \
        "$launcher_dir/Release/uzdoom" \
        "$launcher_dir/../build/sol-local/uzdoom" \
        "$launcher_dir/../build/sol-local/Release/uzdoom" \
        "$launcher_dir/../build/uzdoom" \
        "$launcher_dir/../build/Release/uzdoom"; do
        if [[ -n $candidate && -x $candidate ]]; then
            realpath "$candidate"
            return 0
        fi
    done
    return 1
}

find_bundle() {
    local candidate engine_dir
    engine_dir=$(dirname "$engine")
    for candidate in \
        "${SOL_BUNDLE:-}" \
        "$launcher_dir/sol.pk3" \
        "$engine_dir/sol.pk3" \
        "$launcher_dir/../build/sol/sol.pk3"; do
        if [[ -n $candidate && -f $candidate ]]; then
            realpath "$candidate"
            return 0
        fi
    done
    return 1
}

engine=$(find_engine) || {
    printf 'SOL engine executable not found.\n' >&2
    exit 1
}
bundle=$(find_bundle) || {
    printf 'SOL runtime bundle sol.pk3 not found. Build it from sol-editor with tools/sol-package.sh.\n' >&2
    exit 1
}

map_name=${1:-E1M1}
if [[ $# -gt 0 ]]; then shift; fi

args=(-file "$bundle")
if [[ -n ${DOOM_IWAD:-} ]]; then
    if [[ ! -f $DOOM_IWAD ]]; then
        printf 'DOOM_IWAD does not exist: %s\n' "$DOOM_IWAD" >&2
        exit 1
    fi
    args=(-iwad "$DOOM_IWAD" "${args[@]}")
fi

# With no DOOM_IWAD override, UZDoom keeps its normal IWAD discovery/picker.
exec "$engine" "${args[@]}" +map "$map_name" "$@"
