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
        "$launcher_dir/Release/uzdoom"; do
        if [[ -n $candidate && -x $candidate ]]; then
            realpath "$candidate"
            return 0
        fi
    done
    return 1
}

engine=$(find_engine) || {
    printf 'SOL engine executable not found beside launcher: %s\n' "$launcher_dir" >&2
    exit 1
}
bundle=${SOL_BUNDLE:-"$launcher_dir/sol.pk3"}
if [[ ! -f $bundle ]]; then
    printf 'SOL runtime bundle not found: %s\n' "$bundle" >&2
    exit 1
fi

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

exec "$engine" "${args[@]}" +map "$map_name" "$@"
