#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/uzdoom" <<'ENGINE'
#!/usr/bin/env bash
printf '%s\n' "$@"
ENGINE
chmod +x "$tmp/uzdoom"
printf 'bundle fixture\n' > "$tmp/sol.pk3"
printf 'IWADfixture' > "$tmp/doom.wad"
install -m 0755 "$root/tools/sol-launcher.sh" "$tmp/sol-engine"

output=$(DOOM_IWAD="$tmp/doom.wad" "$tmp/sol-engine" E1M1 -skill 3)
printf '%s\n' "$output" > "$tmp/args"
grep -Fx -- '-iwad' "$tmp/args"
grep -Fx "$tmp/doom.wad" "$tmp/args"
grep -Fx -- '-file' "$tmp/args"
grep -Fx "$tmp/sol.pk3" "$tmp/args"
grep -Fx '+map' "$tmp/args"
grep -Fx 'E1M1' "$tmp/args"
grep -Fx -- '-skill' "$tmp/args"
grep -Fx '3' "$tmp/args"

# Without DOOM_IWAD, keep UZDoom's normal IWAD discovery/picker behavior.
output=$(env -u DOOM_IWAD "$tmp/sol-engine" E1M1)
printf '%s\n' "$output" > "$tmp/no-iwad-args"
! grep -Fx -- '-iwad' "$tmp/no-iwad-args"
grep -Fx -- '-file' "$tmp/no-iwad-args"
grep -Fx "$tmp/sol.pk3" "$tmp/no-iwad-args"

rm "$tmp/sol.pk3"
if "$tmp/sol-engine" E1M1 >/dev/null 2>&1; then
    printf 'SOL launcher accepted a missing sol.pk3\n' >&2
    exit 1
fi

printf 'self-contained SOL engine launcher tests passed\n'
