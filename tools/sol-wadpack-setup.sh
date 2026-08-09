#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
workspace=${SOL_WORKSPACE:-$(cd "$root/.." && pwd)}
vend_root=${SOL_VEND_ROOT:-${SOL_VEND:-"$workspace/vend"}}
manifest=${SOL_WADPACK_MANIFEST:-"$root/sol/wadpack.json"}
allow_missing=0
status_only=0
declare -a sources=()

usage() {
    cat <<'USAGE'
Usage: tools/sol-wadpack-setup.sh [options]

Import, normalize, lock, and verify the engine-owned SOL wadpack.

Options:
  --source PATH       Search one file or directory; may be repeated
  --status            Show the current locked wadpack
  --allow-missing     Import everything found without requiring completion
  --vend DIR          Override the SOL vend directory
  --manifest FILE     Override the engine-owned wadpack manifest
  -h, --help          Show this help
USAGE
}

while (($#)); do
    case $1 in
        --source) sources+=("$2"); shift 2 ;;
        --status) status_only=1; shift ;;
        --allow-missing) allow_missing=1; shift ;;
        --vend) vend_root=$2; shift 2 ;;
        --manifest) manifest=$2; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n' "$1" >&2; exit 2 ;;
    esac
done

vend_root=$(realpath -m "$vend_root")
manifest=$(realpath -m "$manifest")
command_args=(python3 "$root/tools/sol-wadpack.py" --manifest "$manifest" --vend "$vend_root")

if ((status_only)); then
    exec "${command_args[@]}" status
fi

if ((${#sources[@]} == 0)); then
    sources+=(
        "$vend_root/wadpack/source"
        "$vend_root/wadpack/runtime"
        "$workspace"
        "${HOME:-$workspace}/Downloads"
        "${HOME:-$workspace}/Desktop"
        "${HOME:-$workspace}/Documents"
    )
fi

args=("${command_args[@]}" import)
for source in "${sources[@]}"; do
    args+=(--scan "$source")
done
((allow_missing)) && args+=(--allow-missing)

"${args[@]}"
"${command_args[@]}" verify
