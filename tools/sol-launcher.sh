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
        "$launcher_dir/sol-engine" \
        "$launcher_dir/Release/sol-engine" \
        "$launcher_dir/../build/sol-local/sol-engine" \
        "$launcher_dir/../build/sol-local/Release/sol-engine" \
        "$launcher_dir/../build/sol-engine" \
        "$launcher_dir/../build/Release/sol-engine"; do
        if [[ -n $candidate && -x $candidate ]]; then
            realpath "$candidate"
            return 0
        fi
    done
    return 1
}

engine=$(find_engine) || {
    printf 'SOL Engine v0.4 executable not found. Build the current checkout before launching.\n' >&2
    exit 1
}

args=()
if [[ -n ${DOOM_IWAD:-} ]]; then
    if [[ ! -f $DOOM_IWAD ]]; then
        printf 'DOOM_IWAD does not exist: %s\n' "$DOOM_IWAD" >&2
        exit 1
    fi
    iwad_path=$(realpath "$DOOM_IWAD")
    args+=(-iwad "$iwad_path")
fi

# Supplying a map is an explicit development warp and therefore marks the
# native run modified. With no map, SOL opens its normal title flow.
if [[ $# -gt 0 && $1 != -* && $1 != +* ]]; then
    map_name=$1
    shift
    args+=(+map "$map_name")
fi

exec "$engine" "${args[@]}" "$@"
