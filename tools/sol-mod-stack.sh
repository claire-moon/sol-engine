#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
manifest=${SOL_MOD_MANIFEST:-"$root/sol/mods/stack.txt"}
mod_root=${SOL_MOD_ROOT:-"$root/../vend/sol-mods"}
mode=${1:---paths}

case $mode in
    --paths|--print0|--check)
        ;;
    *)
        printf 'Usage: %s [--paths|--print0|--check]\n' "$0" >&2
        exit 2
        ;;
esac

if [[ ! -f $manifest ]]; then
    printf 'SOL mod manifest not found: %s\n' "$manifest" >&2
    exit 1
fi
if [[ ! -d $mod_root ]]; then
    printf 'SOL mod directory not found: %s\n' "$mod_root" >&2
    exit 1
fi

manifest=$(realpath "$manifest")
mod_root=$(realpath "$mod_root")
declare -a files=()

while IFS= read -r entry || [[ -n $entry ]]; do
    entry=${entry%$'\r'}
    [[ -z $entry || $entry == \#* ]] && continue
    if [[ $entry == */* || $entry == .* ]]; then
        printf 'Invalid SOL mod manifest entry: %s\n' "$entry" >&2
        exit 1
    fi
    path="$mod_root/$entry"
    if [[ ! -f $path ]]; then
        printf 'Missing required SOL mod: %s\n' "$path" >&2
        exit 1
    fi
    files+=("$path")
done < "$manifest"

if ((${#files[@]} != 8)); then
    printf 'SOL v0.1.0 requires exactly 8 fixed mods; manifest resolved %d.\n' "${#files[@]}" >&2
    exit 1
fi

case $mode in
    --paths)
        printf '%s\n' "${files[@]}"
        ;;
    --print0)
        printf '%s\0' "${files[@]}"
        ;;
    --check)
        printf 'SOL mod stack OK: %d files in %s\n' "${#files[@]}" "$mod_root"
        ;;
esac
