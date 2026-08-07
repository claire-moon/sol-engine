#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
manifest="$root/sol/mods/stack.json"
mod_root=${SOL_MOD_ROOT:-"$root/../vend/mods/runtime"}

usage() {
    cat <<'EOF'
Usage: tools/sol-stack.sh [--root DIR] [--manifest FILE]

Print the mandatory SOL mod files in deterministic load order, one path per
line. The command fails if the manifest is invalid or any required file is
missing.
EOF
}

while (($#)); do
    case $1 in
        --root)
            mod_root=$2
            shift 2
            ;;
        --manifest)
            manifest=$2
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'Unknown option: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if [[ ! -f $manifest ]]; then
    printf 'SOL mod manifest not found: %s\n' "$manifest" >&2
    exit 1
fi

mod_root=$(realpath -m "$mod_root")

python3 - "$manifest" "$mod_root" <<'PY'
import json
import os
import sys

manifest, root = sys.argv[1:]
with open(manifest, encoding="utf-8") as handle:
    data = json.load(handle)

if data.get("schema") != 1:
    raise SystemExit("Unsupported SOL mod manifest schema")
mods = data.get("mods")
if not isinstance(mods, list) or not mods:
    raise SystemExit("SOL mod manifest contains no mods")

seen = set()
paths = []
for index, mod in enumerate(mods, 1):
    if not isinstance(mod, dict):
        raise SystemExit(f"SOL mod entry {index} is invalid")
    mount = mod.get("mount")
    if not isinstance(mount, str) or not mount or os.path.basename(mount) != mount:
        raise SystemExit(f"SOL mod entry {index} has an invalid mount name")
    if mount in seen:
        raise SystemExit(f"Duplicate SOL mod mount name: {mount}")
    seen.add(mount)
    path = os.path.join(root, mount)
    if not os.path.isfile(path):
        raise SystemExit(f"Missing mandatory SOL mod: {path}")
    paths.append(path)

for path in paths:
    print(path)
PY
