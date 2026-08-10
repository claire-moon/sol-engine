#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$root/sol/game"
version_file="$root/sol/version.json"
out_dir="$root/build/sol"

for command in python3 zip; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf 'Missing required command: %s\n' "$command" >&2
        exit 1
    fi
done

for required in \
    ZSCRIPT \
    MAPINFO \
    SOLDEFAULTS.json \
    zscript/sol/story_ids.zs \
    zscript/sol/story_state.zs \
    zscript/sol/portal_guard.zs \
    zscript/sol/bootstrap.zs; do
    if [[ ! -f "$source_dir/$required" ]]; then
        printf 'Missing SOL runtime file: %s\n' "$required" >&2
        exit 1
    fi
done

version=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["version"])' "$version_file")
archive="$out_dir/sol-v${version}.pk3"

mkdir -p "$out_dir"
rm -f "$archive"

(
    cd "$source_dir"
    find . -type f -print0 \
        | LC_ALL=C sort -z \
        | xargs -0 zip -X -q "$archive"
)

printf '%s\n' "$archive"
