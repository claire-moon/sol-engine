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
elif [[ -x "$root/build/uzdoom" ]]; then
    engine="$root/build/uzdoom"
elif [[ -x "$root/build/Release/uzdoom" ]]; then
    engine="$root/build/Release/uzdoom"
elif command -v uzdoom >/dev/null 2>&1; then
    engine=$(command -v uzdoom)
else
    printf 'SOL engine not found. Set SOL_ENGINE=/path/to/uzdoom.\n' >&2
    exit 1
fi

args=(-file "$package")
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
