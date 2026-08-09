#!/usr/bin/env python3
"""Build, verify, and materialize SOL bundle contract 2."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import tempfile
import zipfile
from pathlib import Path
from typing import Any, Iterable

SCHEMA = 2
BUNDLE_CONTRACT = 2
WADPACK_CONTRACT = 3
VALID_STATES = {'active', 'retired', 'reserved'}
EPOCH = (1980, 1, 1, 0, 0, 0)
BINARY_COMPRESSION = zipfile.ZIP_STORED
TEXT_COMPRESSION = zipfile.ZIP_DEFLATED
CARRIER_RE = re.compile(r'^(\d{2})-[a-z0-9][a-z0-9._-]*\.wad$')


def die(message: str, code: int = 1) -> None:
    print(message, file=os.sys.stderr)
    raise SystemExit(code)


def sha256_path(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open('rb') as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def sha256_stream(handle: Any) -> str:
    digest = hashlib.sha256()
    for block in iter(lambda: handle.read(1024 * 1024), b''):
        digest.update(block)
    return digest.hexdigest()


def read_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding='utf-8'))


def active_items(manifest: dict[str, Any]) -> list[dict[str, Any]]:
    return [item for item in manifest['slots'] if item['state'] == 'active']


def validate_manifest(manifest: dict[str, Any]) -> None:
    if manifest.get('schema') != SCHEMA or manifest.get('wadpack_contract') != WADPACK_CONTRACT:
        die('Unsupported SOL wadpack manifest')
    slots = manifest.get('slots')
    if not isinstance(slots, list) or [item.get('slot') for item in slots] != list(range(1, 21)):
        die('SOL wadpack manifest must define slots 1 through 20')
    if any(item.get('state') not in VALID_STATES for item in slots):
        die('SOL wadpack manifest contains an invalid slot state')
    active = active_items(manifest)
    if len(active) != manifest.get('active_entries'):
        die('SOL wadpack active entry count does not match the manifest')
    if manifest.get('runtime_slot') != 21 or manifest.get('content_slot') != 22:
        die('SOL runtime/content slots must be 21 and 22')


def zip_info(name: str, compression: int) -> zipfile.ZipInfo:
    info = zipfile.ZipInfo(name, EPOCH)
    info.compress_type = compression
    info.external_attr = 0o100644 << 16
    return info


def runtime_inputs(manifest: dict[str, Any], vend: Path) -> list[tuple[dict[str, Any], Path, str]]:
    lock_path = vend / 'wadpack' / 'lock.json'
    if not lock_path.is_file():
        die(f'SOL wadpack lock is missing: {lock_path}')
    lock = read_json(lock_path)
    if lock.get('wadpack_contract') != WADPACK_CONTRACT:
        die(f'SOL wadpack lock has the wrong contract: {lock_path}')
    locked = {entry['id']: entry for entry in lock.get('files', [])}
    result: list[tuple[dict[str, Any], Path, str]] = []
    runtime_dir = vend / 'wadpack' / 'runtime'
    for item in active_items(manifest):
        path = runtime_dir / item['runtime_name']
        entry = locked.get(item['id'])
        if not path.is_file() or entry is None or entry.get('slot') != item['slot']:
            die(f'Missing locked SOL resource: {item["display_name"]}: {path}')
        actual = sha256_path(path)
        if actual != entry.get('runtime_sha256'):
            die(f'Changed locked SOL resource: {item["display_name"]}: {path}')
        result.append((item, path, actual))
    return result


def carrier_name(slot: int, ident: str) -> str:
    safe = re.sub(r'[^a-z0-9._-]+', '-', ident.casefold()).strip('-')
    if not safe:
        die(f'Cannot derive embedded carrier name for slot {slot}')
    return f'{slot:02d}-{safe}.wad'


def component_record(slot: int, kind: str, ident: str, display_name: str,
                     archive_name: str, runtime_name: str, digest: str,
                     distribution: str) -> dict[str, Any]:
    return {
        'slot': slot,
        'state': 'active',
        'kind': kind,
        'id': ident,
        'display_name': display_name,
        'archive': archive_name,
        'runtime_name': runtime_name,
        'sha256': digest,
        'distribution': distribution,
    }


def metadata_slots(manifest: dict[str, Any]) -> list[dict[str, Any]]:
    slots = []
    for item in manifest['slots']:
        record = {
            'slot': item['slot'],
            'state': item['state'],
            'kind': item.get('kind', 'wadpack'),
        }
        if item.get('id') is not None:
            record['id'] = item['id']
        slots.append(record)
    slots.append({'slot': manifest['runtime_slot'], 'state': 'active',
                  'kind': 'runtime', 'id': 'sol-runtime'})
    slots.append({'slot': manifest['content_slot'], 'state': 'active',
                  'kind': 'content', 'id': 'sol-content'})
    return slots


def expected_contract(manifest_path: Path | None,
                      version_path: Path | None) -> dict[str, Any] | None:
    if manifest_path is None and version_path is None:
        return None
    if manifest_path is None or version_path is None:
        die('--manifest and --version-file must be supplied together for contract validation')
    manifest = read_json(manifest_path)
    version = read_json(version_path)
    validate_manifest(manifest)
    active = active_items(manifest)
    return {
        'version': version.get('bundle_version', version['version']),
        'bundle_contract': version.get('bundle_contract'),
        'bundle_name': version.get('bundle_name'),
        'wadpack_contract': version['wadpack_contract'],
        'wadpack_entries': version['wadpack_entries'],
        'slots': metadata_slots(manifest),
        'active_slots': [item['slot'] for item in active],
        'ids': [item['id'] for item in active],
        'runtime_names': [item['runtime_name'] for item in active],
        'runtime_slot': manifest['runtime_slot'],
        'content_slot': manifest['content_slot'],
    }


def validate_slot_table(slots: list[dict[str, Any]]) -> None:
    if [entry.get('slot') for entry in slots] != list(range(1, 23)):
        die('SOL bundle slot table must define slots 1 through 22')
    for entry in slots:
        if entry.get('state') not in VALID_STATES:
            die(f'Invalid SOL bundle slot state at {entry.get("slot")}')
        if entry.get('kind') not in {'wadpack', 'runtime', 'content'}:
            die(f'Invalid SOL bundle slot kind at {entry.get("slot")}')
    if slots[20].get('kind') != 'runtime' or slots[20].get('state') != 'active':
        die('SOL bundle slot 21 must be the active runtime')
    if slots[21].get('kind') != 'content' or slots[21].get('state') != 'active':
        die('SOL bundle slot 22 must be the active content')


def validate_component_table(components: list[dict[str, Any]],
                             slots: list[dict[str, Any]]) -> None:
    if not components:
        die('SOL bundle component table is empty')
    archives = [entry.get('archive') for entry in components]
    component_slots = [entry.get('slot') for entry in components]
    if len(archives) != len(set(archives)) or len(component_slots) != len(set(component_slots)):
        die('SOL bundle contains duplicate component slots or carrier names')

    by_slot = {entry['slot']: entry for entry in slots}
    for entry in components:
        slot = entry.get('slot')
        if not isinstance(slot, int) or slot not in by_slot:
            die('SOL bundle contains an invalid physical component slot')
        if entry.get('state') != 'active' or by_slot[slot].get('state') != 'active':
            die(f'SOL bundle physically contains inactive slot {slot}')
        if entry.get('kind') != by_slot[slot].get('kind'):
            die(f'SOL bundle component kind disagrees at slot {slot}')
        if entry.get('id') != by_slot[slot].get('id'):
            die(f'SOL bundle component ID disagrees at slot {slot}')
        archive = str(entry.get('archive', ''))
        match = CARRIER_RE.fullmatch(archive)
        if match is None or int(match.group(1)) != slot:
            die(f'Invalid native embedded carrier name: {archive}')
        runtime_name = str(entry.get('runtime_name', ''))
        if not runtime_name or '/' in runtime_name or '\\' in runtime_name:
            die(f'Invalid materialized runtime name: {runtime_name}')

    kinds = [entry.get('kind') for entry in components]
    if kinds.count('runtime') != 1 or kinds.count('content') != 1:
        die('SOL bundle must contain one runtime and one content component')
    if any(kind not in {'wadpack', 'runtime', 'content'} for kind in kinds):
        die('SOL bundle contains an unexpected component kind')

    mounted_slots = set(component_slots)
    for entry in slots:
        if entry['state'] in {'retired', 'reserved'} and entry['slot'] in mounted_slots:
            die(f'SOL bundle mounts inactive slot {entry["slot"]}')


def validate_contract(metadata: dict[str, Any], expected: dict[str, Any] | None) -> None:
    if metadata.get('schema') != SCHEMA or metadata.get('project') != 'SOL':
        die('Unsupported SOL bundle metadata')
    slots = metadata.get('slots')
    components = metadata.get('components')
    if not isinstance(slots, list) or not isinstance(components, list):
        die('SOL bundle slot or component table is missing')
    validate_slot_table(slots)
    validate_component_table(components, slots)
    if expected is None:
        return
    if metadata.get('version') != expected['version']:
        die('SOL bundle version does not match this checkout')
    if metadata.get('bundle_contract') != expected['bundle_contract']:
        die('SOL bundle contract does not match this checkout')
    if expected['bundle_name'] not in (None, 'sol.pk3'):
        die('Unsupported SOL bundle filename contract')
    if metadata.get('wadpack_contract') != expected['wadpack_contract']:
        die('SOL bundle wadpack contract does not match this checkout')
    if metadata.get('wadpack_entries') != expected['wadpack_entries']:
        die('SOL bundle wadpack entry count does not match this checkout')
    if slots != expected['slots']:
        die('SOL bundle slot table does not match this checkout')

    wadpack = [entry for entry in components if entry.get('kind') == 'wadpack']
    if [entry.get('slot') for entry in wadpack] != expected['active_slots']:
        die('SOL bundle active wadpack slots do not match this checkout')
    if [entry.get('id') for entry in wadpack] != expected['ids']:
        die('SOL bundle wadpack IDs do not match this checkout')
    if [entry.get('runtime_name') for entry in wadpack] != expected['runtime_names']:
        die('SOL bundle materialized runtime names do not match this checkout')


def verify_bundle(bundle: Path,
                  expected: dict[str, Any] | None = None) -> dict[str, Any]:
    if not bundle.is_file():
        die(f'SOL bundle does not exist: {bundle}')
    try:
        with zipfile.ZipFile(bundle) as archive:
            names = archive.namelist()
            if len(names) != len(set(names)):
                die('SOL bundle contains duplicate ZIP members')
            if 'SOLPACK.json' not in names or 'THIRD_PARTY.md' not in names:
                die('SOL bundle is missing metadata or attribution')
            metadata = json.loads(archive.read('SOLPACK.json').decode('utf-8'))
            validate_contract(metadata, expected)
            expected_names = {'SOLPACK.json', 'THIRD_PARTY.md'}
            expected_names.update(entry['archive'] for entry in metadata['components'])
            if set(names) != expected_names:
                die('SOL bundle contains unexpected or missing members')
            with archive.open('THIRD_PARTY.md') as handle:
                if sha256_stream(handle) != metadata.get('credits_sha256'):
                    die('SOL bundle attribution file hash mismatch')
            for entry in metadata['components']:
                with archive.open(entry['archive']) as handle:
                    if sha256_stream(handle) != entry['sha256']:
                        die(f'SOL bundle component hash mismatch: {entry["archive"]}')
            bad = archive.testzip()
            if bad is not None:
                die(f'SOL bundle ZIP integrity failure: {bad}')
            return metadata
    except (OSError, zipfile.BadZipFile, UnicodeDecodeError,
            json.JSONDecodeError, KeyError) as exc:
        die(f'Invalid SOL bundle {bundle}: {exc}')
    raise AssertionError('unreachable')


def one_component(metadata: dict[str, Any], kind: str) -> dict[str, Any]:
    matches = [entry for entry in metadata['components'] if entry.get('kind') == kind]
    if len(matches) != 1:
        die(f'SOL bundle must contain exactly one {kind} component')
    return matches[0]


def verify_live_inputs(metadata: dict[str, Any], runtime: Path | None,
                       content: Path | None, credits: Path | None) -> None:
    for path, kind in ((runtime, 'runtime'), (content, 'content')):
        if path is None:
            continue
        if not path.is_file():
            die(f'Current SOL {kind} component is missing: {path}')
        if sha256_path(path) != one_component(metadata, kind)['sha256']:
            die(f'SOL bundle contains a stale {kind} component')
    if credits is not None:
        if not credits.is_file():
            die(f'Current SOL attribution file is missing: {credits}')
        if sha256_path(credits) != metadata.get('credits_sha256'):
            die('SOL bundle contains a stale attribution file')


def build_bundle(args: argparse.Namespace) -> None:
    manifest = read_json(args.manifest)
    version = read_json(args.version_file)
    validate_manifest(manifest)
    if version.get('wadpack_contract') != WADPACK_CONTRACT:
        die('SOL version metadata has an unsupported wadpack contract')
    if version.get('wadpack_entries') != manifest.get('active_entries'):
        die('SOL version metadata and active wadpack entry count disagree')
    if version.get('bundle_contract') != BUNDLE_CONTRACT or version.get('bundle_name') != 'sol.pk3':
        die('SOL version metadata has an unsupported bundle contract')
    if not args.runtime.is_file():
        die(f'SOL runtime component is missing: {args.runtime}')
    if not args.content.is_file():
        die(f'SOL content component is missing: {args.content}')
    if not args.credits.is_file():
        die(f'SOL attribution file is missing: {args.credits}')

    inputs = runtime_inputs(manifest, args.vend)
    components: list[dict[str, Any]] = []
    sources: list[tuple[str, Path]] = []
    for item, path, digest in inputs:
        archive_name = carrier_name(item['slot'], item['id'])
        components.append(component_record(
            item['slot'], 'wadpack', item['id'], item['display_name'], archive_name,
            item['runtime_name'], digest, item.get('distribution', 'unknown')))
        sources.append((archive_name, path))

    runtime_slot = manifest['runtime_slot']
    runtime_digest = sha256_path(args.runtime)
    runtime_archive = carrier_name(runtime_slot, 'sol-runtime')
    components.append(component_record(
        runtime_slot, 'runtime', 'sol-runtime', 'SOL runtime', runtime_archive,
        args.runtime.name, runtime_digest, 'SOL-project'))
    sources.append((runtime_archive, args.runtime))

    content_slot = manifest['content_slot']
    content_digest = sha256_path(args.content)
    content_archive = carrier_name(content_slot, 'sol-content')
    components.append(component_record(
        content_slot, 'content', 'sol-content', 'SOL test content', content_archive,
        args.content.name, content_digest, 'SOL-project'))
    sources.append((content_archive, args.content))

    components.sort(key=lambda entry: entry['slot'])
    sources.sort(key=lambda entry: entry[0])
    metadata = {
        'schema': SCHEMA,
        'project': 'SOL',
        'version': version.get('bundle_version', version['version']),
        'bundle_contract': version['bundle_contract'],
        'native_embedding': 'uzdoom-root-wad-carriers',
        'wadpack_contract': version['wadpack_contract'],
        'wadpack_entries': version['wadpack_entries'],
        'distribution': 'local-build-only-until-third-party-audit',
        'credits': 'THIRD_PARTY.md',
        'credits_sha256': sha256_path(args.credits),
        'slots': metadata_slots(manifest),
        'components': components,
    }
    metadata_bytes = (json.dumps(metadata, indent=2, sort_keys=True) + '\n').encode('utf-8')

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=args.output.parent, delete=False) as tmp:
        tmp_path = Path(tmp.name)
    try:
        with zipfile.ZipFile(tmp_path, 'w', allowZip64=True) as archive:
            archive.writestr(zip_info('SOLPACK.json', TEXT_COMPRESSION), metadata_bytes)
            archive.writestr(zip_info('THIRD_PARTY.md', TEXT_COMPRESSION),
                             args.credits.read_bytes())
            for archive_name, source in sources:
                info = zip_info(archive_name, BINARY_COMPRESSION)
                with source.open('rb') as src, archive.open(info, 'w', force_zip64=True) as dst:
                    for block in iter(lambda: src.read(1024 * 1024), b''):
                        dst.write(block)
        os.chmod(tmp_path, 0o644)
        tmp_path.replace(args.output)
    finally:
        tmp_path.unlink(missing_ok=True)

    expected = expected_contract(args.manifest, args.version_file)
    metadata = verify_bundle(args.output, expected)
    verify_live_inputs(metadata, args.runtime, args.content, args.credits)
    print(args.output)


def selected_components(metadata: dict[str, Any], scope: str) -> Iterable[dict[str, Any]]:
    for entry in metadata['components']:
        if scope == 'wadpack' and entry['kind'] != 'wadpack':
            continue
        if scope == 'engine' and entry['kind'] == 'content':
            continue
        yield entry


def materialize(args: argparse.Namespace) -> None:
    expected = expected_contract(args.manifest, args.version_file)
    metadata = verify_bundle(args.bundle, expected)
    bundle_digest = sha256_path(args.bundle)
    root = args.directory / bundle_digest
    root.mkdir(parents=True, exist_ok=True)
    paths: list[Path] = []
    with zipfile.ZipFile(args.bundle) as archive:
        for entry in selected_components(metadata, args.scope):
            destination = root / entry['runtime_name']
            if not destination.is_file() or sha256_path(destination) != entry['sha256']:
                with tempfile.NamedTemporaryFile(dir=root, delete=False) as tmp:
                    tmp_path = Path(tmp.name)
                    with archive.open(entry['archive']) as src:
                        for block in iter(lambda: src.read(1024 * 1024), b''):
                            tmp.write(block)
                os.chmod(tmp_path, 0o644)
                tmp_path.replace(destination)
            paths.append(destination)
    list_path = root / f'load-order-{args.scope}.txt'
    list_path.write_text(''.join(f'{path}\n' for path in paths), encoding='utf-8')
    for path in paths:
        print(path)


def main() -> None:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest='command', required=True)

    build = sub.add_parser('build')
    build.add_argument('--manifest', type=Path, required=True)
    build.add_argument('--version-file', type=Path, required=True)
    build.add_argument('--vend', type=Path, required=True)
    build.add_argument('--runtime', type=Path, required=True)
    build.add_argument('--content', type=Path, required=True)
    build.add_argument('--credits', type=Path, required=True)
    build.add_argument('--output', type=Path, required=True)

    verify = sub.add_parser('verify')
    verify.add_argument('--bundle', type=Path, required=True)
    verify.add_argument('--manifest', type=Path)
    verify.add_argument('--version-file', type=Path)
    verify.add_argument('--runtime', type=Path)
    verify.add_argument('--content', type=Path)
    verify.add_argument('--credits', type=Path)

    extract = sub.add_parser('materialize')
    extract.add_argument('--bundle', type=Path, required=True)
    extract.add_argument('--directory', type=Path, required=True)
    extract.add_argument('--scope', choices=('wadpack', 'engine', 'all'), default='all')
    extract.add_argument('--manifest', type=Path)
    extract.add_argument('--version-file', type=Path)

    args = parser.parse_args()
    if args.command == 'build':
        build_bundle(args)
    elif args.command == 'verify':
        expected = expected_contract(args.manifest, args.version_file)
        metadata = verify_bundle(args.bundle, expected)
        verify_live_inputs(metadata, args.runtime, args.content, args.credits)
        print(args.bundle)
    elif args.command == 'materialize':
        materialize(args)


if __name__ == '__main__':
    main()
