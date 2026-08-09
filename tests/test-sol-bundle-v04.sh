#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/vend/wadpack/runtime"

python3 - "$root" "$tmp" <<'PY'
import hashlib
import json
import sys
from pathlib import Path
root = Path(sys.argv[1])
tmp = Path(sys.argv[2])
manifest = json.loads((root / 'sol/wadpack.json').read_text())
runtime = tmp / 'vend/wadpack/runtime'
files = []
for item in manifest['slots']:
    if item['state'] != 'active':
        continue
    path = runtime / item['runtime_name']
    path.write_bytes((f"SOL test slot {item['slot']:02d} {item['id']}\n").encode())
    files.append({
        'slot': item['slot'],
        'id': item['id'],
        'runtime_sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
    })
lock = {
    'schema': 2,
    'wadpack_contract': 3,
    'manifest_name': manifest['name'],
    'manifest_version': manifest['version'],
    'active_entries': manifest['active_entries'],
    'files': files,
    'missing': [],
}
(tmp / 'vend/wadpack/lock.json').write_text(json.dumps(lock, indent=2, sort_keys=True) + '\n')
(tmp / 'runtime.pk3').write_bytes(b'SOL runtime fixture\n')
(tmp / 'content.pk3').write_bytes(b'SOL content fixture\n')
PY

python3 "$root/tools/sol-bundle.py" build \
    --manifest "$root/sol/wadpack.json" \
    --version-file "$root/sol/version.json" \
    --vend "$tmp/vend" \
    --runtime "$tmp/runtime.pk3" \
    --content "$tmp/content.pk3" \
    --credits "$root/THIRD_PARTY.md" \
    --output "$tmp/sol.pk3" >/dev/null

python3 "$root/tools/sol-bundle.py" verify \
    --bundle "$tmp/sol.pk3" \
    --manifest "$root/sol/wadpack.json" \
    --version-file "$root/sol/version.json" >/dev/null

python3 - "$tmp/sol.pk3" <<'PY'
import json
import sys
import zipfile
with zipfile.ZipFile(sys.argv[1]) as archive:
    names = archive.namelist()
    metadata = json.loads(archive.read('SOLPACK.json'))
assert metadata['schema'] == 2
assert metadata['bundle_contract'] == 2
assert metadata['wadpack_contract'] == 3
assert len(metadata['slots']) == 22
assert metadata['slots'][10]['state'] == 'retired'
assert metadata['slots'][18]['id'] == 'precise-crosshair'
assert metadata['slots'][19]['state'] == 'reserved'
assert metadata['slots'][20] == {'id': 'sol-runtime', 'kind': 'runtime', 'slot': 21, 'state': 'active'}
assert metadata['slots'][21] == {'id': 'sol-content', 'kind': 'content', 'slot': 22, 'state': 'active'}
assert not any(name.startswith('11-') for name in names)
assert not any(name.startswith('20-') for name in names)
assert any(name.startswith('19-precise-crosshair') for name in names)
assert any(name.startswith('21-sol-runtime') for name in names)
assert any(name.startswith('22-sol-content') for name in names)
PY
