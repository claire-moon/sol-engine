#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
map_name=${1:-}
if [[ $# -gt 0 ]]; then
    shift
fi

package=$(bash "$root/tools/sol-package.sh")

if [[ -n ${SOL_ENGINE:-} ]]; then
    engine=$SOL_ENGINE
else
    engine=
    for candidate in \
        "$root/build/uzdoom" \
        "$root/build/Release/uzdoom" \
        "$root/build/Debug/uzdoom" \
        "$root/build/src/uzdoom" \
        "$root/build/sol-engine" \
        "$root/uzdoom"; do
        if [[ -x $candidate ]]; then
            engine=$candidate
            break
        fi
    done
fi

if [[ -z $engine ]]; then
    printf 'Built SOL engine not found. Set SOL_ENGINE=/path/to/local/sol-engine/uzdoom.\n' >&2
    exit 1
fi
if [[ ! -x $engine ]]; then
    printf 'SOL_ENGINE is not executable: %s\n' "$engine" >&2
    exit 1
fi

stack_text=$(bash "$root/tools/sol-stack.sh")
mapfile -t sol_mods <<<"$stack_text"
if ((${#sol_mods[@]} == 0)); then
    printf 'SOL mandatory mod stack is empty.\n' >&2
    exit 1
fi

packages=("$package" "${sol_mods[@]}")
args=(-file "${packages[@]}")
if [[ -n ${DOOM_IWAD:-} ]]; then
    if [[ ! -f $DOOM_IWAD ]]; then
        printf 'DOOM_IWAD does not exist: %s\n' "$DOOM_IWAD" >&2
        exit 1
    fi
    args=(-iwad "$DOOM_IWAD" "${args[@]}")
fi
if [[ -n $map_name ]]; then
    args+=(+map "$map_name")
fi

exec "$engine" "${args[@]}" "$@"
