#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

c++ -std=c++17 -I"$root/src" -I"$root/src/common" -I"$root/src/common/utility" -I"$root/src/utility" \
    "$root/tests/test-sol-phaseportal.cpp" -o "$tmp/test-sol-phaseportal"
"$tmp/test-sol-phaseportal"

printf 'SOL phase-portal deterministic state-machine tests passed\n'
