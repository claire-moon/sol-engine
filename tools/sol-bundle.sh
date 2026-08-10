#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
workspace=${SOL_WORKSPACE:-$(cd "$root/.." && pwd)}
editor_root=${SOL_EDITOR_ROOT:-"$workspace/sol-editor"}
vend_root=${SOL_VEND_ROOT:-${SOL_VEND:-"$workspace/vend"}}
manifest=${SOL_WADPACK_MANIFEST:-"$root/sol/wadpack.json"}
version_file=${SOL_VERSION_FILE:-"$root/sol/version.json"}
credits=${SOL_THIRD_PARTY_FILE:-"$root/THIRD_PARTY.md"}
bundle=${SOL_BUNDLE:-"$root/build/sol/sol.pk3"}
bundle_tool=(python3 "$root/tools/sol-bundle.py")
wadpack_tool=(python3 "$root/tools/sol-wadpack.py" --manifest "$manifest" --vend "$vend_root")

copy_bundle() {
    local destination=$1
    mkdir -p "$(dirname "$destination")"
    if [[ $(realpath -m "$bundle") != $(realpath -m "$destination") ]]; then
        cp -f "$bundle" "$destination"
    fi
}

install_bundle_copies() {
    copy_bundle "$root/build/sol/sol.pk3"
    if [[ -d $root/build/sol-local ]]; then
        copy_bundle "$root/build/sol-local/sol.pk3"
    fi
    if [[ -n ${SOL_ENGINE:-} && -f ${SOL_ENGINE:-} ]]; then
        copy_bundle "$(dirname "$(realpath "$SOL_ENGINE")")/sol.pk3"
    fi
    if [[ -d $editor_root/Build ]]; then
        copy_bundle "$editor_root/Build/sol.pk3"
    fi
    if [[ -n ${SOL_EDITOR:-} && -f ${SOL_EDITOR:-} ]]; then
        copy_bundle "$(dirname "$(realpath "$SOL_EDITOR")")/sol.pk3"
    fi
}

bundle_valid=0
if [[ -f $bundle ]] && "${bundle_tool[@]}" verify \
    --bundle "$bundle" --manifest "$manifest" --version-file "$version_file" \
    >/dev/null 2>&1; then
    bundle_valid=1
fi

wadpack_ready=0
if "${wadpack_tool[@]}" verify >/dev/null 2>&1; then
    wadpack_ready=1
fi

if ((bundle_valid)) && [[ ${SOL_BUNDLE_REUSE:-0} == 1 ]]; then
    install_bundle_copies
    printf '%s\n' "$bundle"
    exit 0
fi

if ((wadpack_ready == 0)); then
    if ((bundle_valid)); then
        install_bundle_copies
        printf '%s\n' "$bundle"
        exit 0
    fi
    if [[ ${SOL_BUNDLE_NO_SETUP:-0} == 1 ]]; then
        printf 'SOL wadpack contract 3 is incomplete and no valid sol.pk3 exists.\n' >&2
        exit 1
    fi
    bash "$root/tools/sol-wadpack-setup.sh"
    "${wadpack_tool[@]}" verify >/dev/null || {
        printf 'SOL wadpack remains incomplete after setup.\n' >&2
        exit 1
    }
fi

runtime_package=${SOL_RUNTIME_COMPONENT:-$(bash "$root/tools/sol-runtime-package.sh")}
if [[ -n ${SOL_CONTENT_COMPONENT:-} ]]; then
    content_package=$SOL_CONTENT_COMPONENT
else
    content_builder="$editor_root/tools/sol-build.sh"
    if [[ ! -f $content_builder ]]; then
        printf 'SOL editor content builder not found: %s\n' "$content_builder" >&2
        exit 1
    fi
    content_package=$(bash "$content_builder")
fi

if ((bundle_valid)) && [[ ${SOL_FORCE_BUNDLE_REFRESH:-0} != 1 ]]; then
    if "${bundle_tool[@]}" verify \
        --bundle "$bundle" --manifest "$manifest" --version-file "$version_file" \
        --runtime "$runtime_package" --content "$content_package" --credits "$credits" \
        >/dev/null 2>&1; then
        install_bundle_copies
        printf '%s\n' "$bundle"
        exit 0
    fi
fi

"${bundle_tool[@]}" build \
    --manifest "$manifest" \
    --version-file "$version_file" \
    --vend "$vend_root" \
    --runtime "$runtime_package" \
    --content "$content_package" \
    --credits "$credits" \
    --output "$bundle" \
    >/dev/null

install_bundle_copies
printf '%s\n' "$bundle"
