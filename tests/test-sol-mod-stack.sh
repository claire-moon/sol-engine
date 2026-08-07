#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mod_root="$tmp/sol-mods"
mkdir -p "$mod_root"

expected=(
    PSSFX.zip
    flashlight_plus_plus_v9_1.7z
    FinalCustomDoom-v1.0.0-beta.pk3
    jdra-Angled-Doom-Lite-1.2.1.pk3
    TrooCullers2.5.pk3
    TiltPlusPlus.pk3
    Universal-Weapon-Sway-master.zip
    nashgore_next.zip
)
for name in "${expected[@]}"; do
    printf 'fixture\n' > "$mod_root/$name"
done

SOL_MOD_ROOT="$mod_root" bash "$root/tools/sol-mod-stack.sh" --check >/dev/null
mapfile -d '' -t actual < <(SOL_MOD_ROOT="$mod_root" bash "$root/tools/sol-mod-stack.sh" --print0)
test "${#actual[@]}" -eq "${#expected[@]}"
for i in "${!expected[@]}"; do
    test "${actual[$i]}" = "$mod_root/${expected[$i]}"
done

rm "$mod_root/${expected[3]}"
if SOL_MOD_ROOT="$mod_root" bash "$root/tools/sol-mod-stack.sh" --check >/dev/null 2>&1; then
    printf 'missing fixed mod was accepted\n' >&2
    exit 1
fi
printf 'fixture\n' > "$mod_root/${expected[3]}"

fake_engine="$tmp/uzdoom"
argv_log="$tmp/argv"
cat > "$fake_engine" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$SOL_ARGV_LOG"
EOF
chmod +x "$fake_engine"
SOL_MOD_ROOT="$mod_root" SOL_ENGINE="$fake_engine" SOL_ARGV_LOG="$argv_log" \
    bash "$root/tools/sol-run.sh" E1M1

mapfile -t argv < "$argv_log"
test "${argv[0]}" = -file
for i in "${!expected[@]}"; do
    test "${argv[$((i + 1))]}" = "$mod_root/${expected[$i]}"
done
runtime_index=$((1 + ${#expected[@]}))
[[ ${argv[$runtime_index]} == "$root"/build/sol/sol-v0.1.0.pk3 ]]
test "${argv[$((runtime_index + 1))]}" = +map
test "${argv[$((runtime_index + 2))]}" = E1M1

printf 'SOL mod stack tests passed\n'
