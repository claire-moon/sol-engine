#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/native-sol-engine" <<'ENGINE'
#!/usr/bin/env bash
printf '%s\n' "$@"
ENGINE
chmod +x "$tmp/native-sol-engine"
printf 'IWADfixture' > "$tmp/doom.wad"
install -m 0755 "$root/tools/sol-launcher.sh" "$tmp/sol-run"

output=$(SOL_ENGINE="$tmp/native-sol-engine" DOOM_IWAD="$tmp/doom.wad" "$tmp/sol-run" E1M1 -skill 3)
printf '%s\n' "$output" > "$tmp/args"
grep -Fx -- '-iwad' "$tmp/args"
grep -Fx "$tmp/doom.wad" "$tmp/args"
! grep -Fx -- '-file' "$tmp/args"
! grep -Fx "$tmp/sol.pk3" "$tmp/args"
grep -Fx '+map' "$tmp/args"
grep -Fx 'E1M1' "$tmp/args"
grep -Fx -- '-skill' "$tmp/args"
grep -Fx '3' "$tmp/args"

# Without overrides, let the native SOL engine own IWAD discovery and title flow.
output=$(env -u DOOM_IWAD SOL_ENGINE="$tmp/native-sol-engine" "$tmp/sol-run")
printf '%s\n' "$output" > "$tmp/no-iwad-args"
! grep -Fx -- '-iwad' "$tmp/no-iwad-args"
! grep -Fx -- '-file' "$tmp/no-iwad-args"
! grep -Fx '+map' "$tmp/no-iwad-args"

printf 'native SOL engine development launcher tests passed\n'
