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
python3 "$root/tools/sol-bundle.py" verify --bundle "$tmp/sol.pk3" >/dev/null

python3 - "$tmp" <<'PY'
import json
import sys
import zipfile
from pathlib import Path

tmp = Path(sys.argv[1])
bundle = tmp / 'sol.pk3'
with zipfile.ZipFile(bundle) as archive:
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
runtime = next(item for item in metadata['components'] if item['kind'] == 'runtime')
content = next(item for item in metadata['components'] if item['kind'] == 'content')
assert runtime['runtime_name'] == 'sol-v0.4.0.pk3'
assert content['runtime_name'] == 'sol-e1m1-v0.4.0.pk3'


def write_tampered(name, mutate):
    target = tmp / name
    with zipfile.ZipFile(bundle) as source, zipfile.ZipFile(target, 'w') as output:
        changed = json.loads(source.read('SOLPACK.json'))
        mutate(changed)
        for info in source.infolist():
            data = source.read(info.filename)
            if info.filename == 'SOLPACK.json':
                data = (json.dumps(changed, indent=2, sort_keys=True) + '\n').encode()
            output.writestr(info, data)

write_tampered('bad-contract.pk3', lambda value: value.__setitem__('bundle_contract', 99))
write_tampered(
    'bad-runtime-name.pk3',
    lambda value: next(item for item in value['components'] if item['kind'] == 'runtime')
        .__setitem__('runtime_name', 'runtime.pk3'),
)
write_tampered('missing-active.pk3', lambda value: value['components'].pop(0))
PY

for invalid in bad-contract.pk3 bad-runtime-name.pk3 missing-active.pk3; do
    if python3 "$root/tools/sol-bundle.py" verify --bundle "$tmp/$invalid" >/dev/null 2>&1; then
        printf 'invalid SOL bundle unexpectedly verified: %s\n' "$invalid" >&2
        exit 1
    fi
done
