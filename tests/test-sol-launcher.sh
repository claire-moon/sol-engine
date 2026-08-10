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

# A stale v0.3 build must never shadow the current sol-local build.
fixture="$tmp/layout"
mkdir -p \
    "$fixture/tools" \
    "$fixture/build/sol-local" \
    "$fixture/build/sol-v030" \
    "$fixture/src/common/startscreen"
install -m 0755 "$root/tools/sol-launcher.sh" "$fixture/tools/sol-launcher.sh"
cat > "$fixture/build/sol-local/sol-engine" <<'CURRENT'
#!/usr/bin/env bash
printf 'CURRENT-V04\n'
CURRENT
cat > "$fixture/build/sol-v030/sol-engine" <<'LEGACY'
#!/usr/bin/env bash
printf 'STALE-V03\n'
LEGACY
chmod +x "$fixture/build/sol-local/sol-engine" "$fixture/build/sol-v030/sol-engine"
printf '#define VERSIONSTR "0.4.0"\n' > "$fixture/src/version.h"
printf 'SOL startup source\n' > "$fixture/src/common/startscreen/startscreen_generic.cpp"
touch -t 202601010100 "$fixture/src/version.h" "$fixture/src/common/startscreen/startscreen_generic.cpp"
touch -t 202601010200 "$fixture/build/sol-local/sol-engine"

output=$(env -u SOL_ENGINE -u DOOM_IWAD bash "$fixture/tools/sol-launcher.sh")
test "$output" = 'CURRENT-V04'

# A local engine older than the current startup/version sources must be rejected.
touch -t 202601010300 "$fixture/src/common/startscreen/startscreen_generic.cpp"
if env -u SOL_ENGINE -u DOOM_IWAD bash "$fixture/tools/sol-launcher.sh" >"$tmp/stale.out" 2>"$tmp/stale.err"; then
    printf 'stale local SOL engine unexpectedly launched\n' >&2
    exit 1
fi
grep -F 'executable is older than the v0.4 source tree' "$tmp/stale.err"
grep -F 'loading screen and engine changes are present' "$tmp/stale.err"

printf 'native SOL engine development launcher tests passed\n'