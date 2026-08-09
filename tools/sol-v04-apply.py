#!/usr/bin/env python3
from pathlib import Path
import textwrap

ROOT = Path(__file__).resolve().parents[1]


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if text.count(old) != 1:
        raise SystemExit(f"{label}: expected one match, found {text.count(old)}")
    return text.replace(old, new, 1)


def patch_d_main() -> None:
    path = ROOT / "src/d_main.cpp"
    text = path.read_text(encoding="utf-8")

    start = text.index("struct SolBundleComponent\n{")
    end = text.index("static FString HashSolBundleEntry", start)
    table = r'''struct SolBundleComponent
{
	int Slot;
	const char* Kind;
	const char* Id;
	const char* Archive;
	const char* RuntimeName;
};

static constexpr SolBundleComponent SolBundleComponents[] = {
	{ 1, "wadpack", "voxel-doom", "01-voxel-doom.wad", "01-voxel-doom-v2.4.pk3" },
	{ 2, "wadpack", "universal-weapon-sway", "02-universal-weapon-sway.wad", "02-universal-weapon-sway.pk3" },
	{ 3, "wadpack", "troo-cullers", "03-troo-cullers.wad", "03-troo-cullers-2.5.pk3" },
	{ 4, "wadpack", "tilt-plus-plus", "04-tilt-plus-plus.wad", "04-tilt-plus-plus.pk3" },
	{ 5, "wadpack", "relite", "05-relite.wad", "05-relite-0.7.3b.pk3" },
	{ 6, "wadpack", "angled-doom-lite", "06-angled-doom-lite.wad", "06-angled-doom-lite-1.2.1.pk3" },
	{ 7, "wadpack", "nashgore-next", "07-nashgore-next.wad", "07-nashgore-next.pk3" },
	{ 8, "wadpack", "nashgore-voxels", "08-nashgore-voxels.wad", "08-nashgore-voxels-official.pk3" },
	{ 9, "wadpack", "final-custom-doom", "09-final-custom-doom.wad", "09-final-custom-doom-v1.0.0-beta.pk3" },
	{ 10, "wadpack", "vanilla-essence", "10-vanilla-essence.wad", "10-vanilla-essence-4.3.pk3" },
	{ 12, "wadpack", "psx-sfx", "12-psx-sfx.wad", "12-psx-sfx.wad" },
	{ 13, "wadpack", "flashlight-plus-plus", "13-flashlight-plus-plus.wad", "13-flashlight-plus-plus-v9_1.pk3" },
	{ 14, "wadpack", "alpha-hud", "14-alpha-hud.wad", "14-ww-alpha-hud.wad" },
	{ 15, "wadpack", "universal-ambience", "15-universal-ambience.wad", "15-universal-ambience.pk3" },
	{ 16, "wadpack", "cosmoambience-script-edited", "16-cosmoambience-script-edited.wad", "16-cosmoambience-script-edited.pk3" },
	{ 17, "wadpack", "ambient-decorations", "17-ambient-decorations.wad", "17-ambient-decorations.pk3" },
	{ 18, "wadpack", "targetspy", "18-targetspy.wad", "18-targetspy-v3.1.0.pk3" },
	{ 19, "wadpack", "precise-crosshair", "19-precise-crosshair.wad", "19-precise-crosshair-v1.5.0.pk3" },
	{ 21, "runtime", "sol-runtime", "21-sol-runtime.wad", "sol-v0.4.0.pk3" },
	{ 22, "content", "sol-content", "22-sol-content.wad", "sol-e1m1-v0.4.0.pk3" },
};

static const SolBundleComponent* SolBundleComponentForSlot(int slot)
{
	for (const auto& component : SolBundleComponents)
	{
		if (component.Slot == slot) return &component;
	}
	return nullptr;
}

'''
    text = text[:start] + table + text[end:]

    start = text.index("static void ValidateSolBundle(const FString& path)")
    end = text.index("\nEXTERN_CVAR(Bool, hud_althud)", start)
    validator = r'''static void ValidateSolBundle(const FString& path)
{
	std::unique_ptr<FResourceFile> bundle(FResourceFile::OpenResourceFile(path.GetChars(), true));
	if (!bundle)
	{
		I_FatalError("Cannot open mandatory SOL runtime bundle %s", path.GetChars());
	}

	int manifestEntry = bundle->FindEntry("SOLPACK.json");
	int creditsEntry = bundle->FindEntry("THIRD_PARTY.md");
	if (manifestEntry < 0 || creditsEntry < 0)
	{
		I_FatalError(
			"%s is not a valid SOL runtime bundle: SOLPACK.json or THIRD_PARTY.md is missing",
			path.GetChars());
	}

	auto data = bundle->Read(manifestEntry);
	FSerializer manifest;
	manifest.mLumpName = "SOLPACK.json";
	if (!manifest.OpenReader(data.string(), data.size()))
	{
		I_FatalError("Cannot parse SOLPACK.json in %s", path.GetChars());
	}

	FString project;
	FString version;
	FString credits;
	FString creditsHash;
	int schema = 0;
	int bundleContract = 0;
	int wadpackContract = 0;
	int wadpackEntries = 0;
	manifest("project", project)
		("version", version)
		("schema", schema)
		("bundle_contract", bundleContract)
		("wadpack_contract", wadpackContract)
		("wadpack_entries", wadpackEntries)
		("credits", credits)
		("credits_sha256", creditsHash);

	unsigned slotCount = 0;
	if (manifest.BeginArray("slots"))
	{
		slotCount = manifest.ArraySize();
		for (unsigned index = 0; index < slotCount; ++index)
		{
			if (!manifest.BeginObject(nullptr))
			{
				I_FatalError("%s has a malformed SOLPACK slot table", path.GetChars());
			}

			int slot = 0;
			FString state;
			FString kind;
			FString id;
			manifest("slot", slot)
				("state", state)
				("kind", kind)
				("id", id);
			manifest.EndObject();

			const int expectedSlot = static_cast<int>(index + 1);
			if (slot != expectedSlot)
			{
				I_FatalError("%s has a non-contiguous SOLPACK slot table at slot %u",
					path.GetChars(), index + 1);
			}

			const auto* expected = SolBundleComponentForSlot(slot);
			if (slot == 11)
			{
				if (state.Compare("retired") != 0 || kind.Compare("wadpack") != 0 ||
					id.Compare("hq-psx-music") != 0)
				{
					I_FatalError("%s does not retire SOLPACK slot 11", path.GetChars());
				}
			}
			else if (slot == 20)
			{
				if (state.Compare("reserved") != 0 || kind.Compare("wadpack") != 0)
				{
					I_FatalError("%s does not reserve SOLPACK slot 20", path.GetChars());
				}
			}
			else if (expected == nullptr || state.Compare("active") != 0 ||
				kind.Compare(expected->Kind) != 0 || id.Compare(expected->Id) != 0)
			{
				I_FatalError("%s has an incompatible SOLPACK slot %d", path.GetChars(), slot);
			}
		}
		manifest.EndArray();
	}

	std::array<FString, countof(SolBundleComponents)> componentHashes;
	unsigned componentCount = 0;
	if (manifest.BeginArray("components"))
	{
		componentCount = manifest.ArraySize();
		for (unsigned index = 0; index < componentCount; ++index)
		{
			if (!manifest.BeginObject(nullptr))
			{
				I_FatalError("%s has a malformed SOLPACK component table", path.GetChars());
			}

			int slot = 0;
			FString state;
			FString kind;
			FString id;
			FString archive;
			FString runtimeName;
			FString hash;
			manifest("slot", slot)
				("state", state)
				("kind", kind)
				("id", id)
				("archive", archive)
				("runtime_name", runtimeName)
				("sha256", hash);
			manifest.EndObject();

			if (index >= countof(SolBundleComponents))
			{
				I_FatalError("%s declares too many SOLPACK components", path.GetChars());
			}
			const auto& expected = SolBundleComponents[index];
			if (slot != expected.Slot || state.Compare("active") != 0 ||
				kind.Compare(expected.Kind) != 0 || id.Compare(expected.Id) != 0 ||
				archive.Compare(expected.Archive) != 0 ||
				runtimeName.Compare(expected.RuntimeName) != 0 || !IsSolSHA256(hash))
			{
				I_FatalError("%s has an incompatible SOLPACK component at slot %d",
					path.GetChars(), expected.Slot);
			}
			componentHashes[index] = hash;
		}
		manifest.EndArray();
	}

	if (project.Compare("SOL") != 0 || version.Compare(VERSIONSTR) != 0 ||
		schema != SOLPACK_SCHEMA || bundleContract != SOLBUNDLE_CONTRACT ||
		wadpackContract != SOL_WADPACK_CONTRACT || wadpackEntries != SOL_WADPACK_ENTRIES ||
		slotCount != SOL_CONTENT_SLOT || componentCount != SOLBUNDLE_COMPONENTS ||
		componentCount != countof(SolBundleComponents) ||
		credits.Compare("THIRD_PARTY.md") != 0 || !IsSolSHA256(creditsHash))
	{
		I_FatalError(
			"%s has an incompatible SOLPACK contract "
			"(schema %d, bundle %d, wadpack %d/%d, slots %u, components %u)",
			path.GetChars(), schema, bundleContract, wadpackContract,
			wadpackEntries, slotCount, componentCount);
	}

	if (bundle->EntryCount() != static_cast<int>(componentCount + 2) ||
		manifestEntry != static_cast<int>(componentCount) ||
		creditsEntry != static_cast<int>(componentCount + 1))
	{
		I_FatalError("%s has unexpected, missing, or misordered root entries", path.GetChars());
	}

	if (HashSolBundleEntry(bundle.get(), creditsEntry, path).CompareNoCase(creditsHash) != 0)
	{
		I_FatalError("%s has a changed THIRD_PARTY.md attribution file", path.GetChars());
	}
	for (unsigned index = 0; index < componentCount; ++index)
	{
		const auto& expected = SolBundleComponents[index];
		const int entry = bundle->FindEntry(expected.Archive);
		if (entry != static_cast<int>(index) ||
			stricmp(bundle->getName(entry), expected.Archive) != 0)
		{
			I_FatalError("%s has a missing or misordered carrier at slot %d",
				path.GetChars(), expected.Slot);
		}
		if (HashSolBundleEntry(bundle.get(), entry, path).CompareNoCase(componentHashes[index]) != 0)
		{
			I_FatalError("%s has a changed carrier at slot %d", path.GetChars(), expected.Slot);
		}
	}
}

static bool SolDefaultCategoryAllowed(const FString& category)
{
	return category.Compare("renderer") == 0 || category.Compare("mod") == 0 ||
		category.Compare("audio") == 0 || category.Compare("hud") == 0 ||
		category.Compare("gameplay") == 0;
}

static bool SOL_ApplyCanonicalDefaults(bool force)
{
	const int lump = fileSystem.CheckNumForFullName("SOLDEFAULTS.json");
	if (lump < 0)
	{
		if (force) Printf(TEXTCOLOR_ORANGE "SOLDEFAULTS.json is not available.\n");
		return false;
	}

	auto data = fileSystem.ReadFile(lump);
	FSerializer defaults;
	defaults.mLumpName = "SOLDEFAULTS.json";
	if (!defaults.OpenReader(data.string(), data.size()))
	{
		I_FatalError("Cannot parse SOLDEFAULTS.json");
	}

	FString project;
	int schema = 0;
	int contract = 0;
	defaults("project", project)("schema", schema)("contract", contract);
	if (project.Compare("SOL") != 0 || schema != 1 || contract != SOLDEFAULTS_CONTRACT)
	{
		I_FatalError("Incompatible SOLDEFAULTS.json contract");
	}

	if (!defaults.BeginArray("values"))
	{
		I_FatalError("SOLDEFAULTS.json has no values table");
	}
	const unsigned count = defaults.ArraySize();
	for (unsigned index = 0; index < count; ++index)
	{
		if (!defaults.BeginObject(nullptr))
		{
			I_FatalError("SOLDEFAULTS.json contains a malformed value");
		}
		FString category;
		FString name;
		FString value;
		defaults("category", category)("name", name)("value", value);
		defaults.EndObject();
		if (!SolDefaultCategoryAllowed(category) || name.IsEmpty())
		{
			I_FatalError("SOLDEFAULTS.json contains an unsupported default entry");
		}

		FBaseCVar* cvar = FindCVar(name.GetChars(), nullptr);
		if (cvar == nullptr)
		{
			Printf(TEXTCOLOR_ORANGE "SOL default skipped unavailable CVAR %s.\n", name.GetChars());
			continue;
		}
		const bool setCurrent = force || (cvar->GetFlags() & CVAR_ISDEFAULT) != 0;
		UCVarValue textValue(value.GetChars());
		cvar->SetGenericRepDefault(textValue, CVAR_String);
		if (setCurrent) cvar->SetGenericRep(textValue, CVAR_String);
	}
	defaults.EndArray();
	return true;
}

CCMD(sol_reset_defaults)
{
	if (SOL_ApplyCanonicalDefaults(true))
	{
		Printf("SOL defaults contract %d restored.\n", SOLDEFAULTS_CONTRACT);
	}
}
'''
    text = text[:start] + validator + text[end:]
    text = replace_once(
        text,
        "\tD_GrabCVarDefaults(); //parse DEFCVARS\n\tInitPalette();",
        "\tD_GrabCVarDefaults(); //parse DEFCVARS\n\tSOL_ApplyCanonicalDefaults(false);\n\tInitPalette();",
        "SOL defaults startup hook",
    )
    path.write_text(text, encoding="utf-8")


def patch_cmake() -> None:
    path = ROOT / "CMakeLists.txt"
    text = path.read_text(encoding="utf-8")
    text = replace_once(text, "project(SOLEngine VERSION 0.3.0)",
                        "project(SOLEngine VERSION 0.4.0)", "CMake project version")
    path.write_text(text, encoding="utf-8")


def write_bundle_test() -> None:
    path = ROOT / "tests/test-sol-bundle-v04.sh"
    path.write_text(r'''#!/usr/bin/env bash
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
''', encoding="utf-8")
    path.chmod(0o755)


def write_workflow() -> None:
    path = ROOT / ".github/workflows/sol-foundation.yml"
    path.write_text(r'''name: SOL engine v0.4 contract

on:
  push:
    branches: [trunk, 'sol/**']
    paths:
      - 'sol/**'
      - 'tools/sol-*'
      - 'tests/**'
      - 'docs/sol/**'
      - 'branding/sol/**'
      - 'branding/misc/appicon*'
      - 'CMakeLists.txt'
      - 'src/**'
      - 'libraries/ZWidget/**'
      - 'wadsrc/**'
      - 'SOL.md'
      - 'ROADMAP.md'
      - 'THIRD_PARTY.md'
      - '.github/workflows/**'
  pull_request:
    paths:
      - 'sol/**'
      - 'tools/sol-*'
      - 'tests/**'
      - 'docs/sol/**'
      - 'branding/sol/**'
      - 'branding/misc/appicon*'
      - 'CMakeLists.txt'
      - 'src/**'
      - 'libraries/ZWidget/**'
      - 'wadsrc/**'
      - 'SOL.md'
      - 'ROADMAP.md'
      - 'THIRD_PARTY.md'
      - '.github/workflows/**'

permissions:
  contents: read

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - name: Validate metadata and scripts
        run: |
          python3 -m json.tool sol/version.json >/dev/null
          python3 -m json.tool sol/wadpack.json >/dev/null
          python3 -m json.tool sol/game/SOLDEFAULTS.json >/dev/null
          python3 -m py_compile tools/sol-bundle.py tools/sol-wadpack.py
          bash -n tools/sol-*.sh tests/*.sh
          grep -F 'tools/sol-launcher.sh' tools/sol-run.sh
          ! grep -F -- '-file' tools/sol-launcher.sh
          ! grep -F 'uzdoom' tools/sol-launcher.sh
          grep -F 'sol-runtime-package.sh' tools/sol-package.sh
          grep -F 'sol-bundle.sh' tools/sol-package.sh
          ! grep -F 'sol-editor/tools/sol-bundle' tools/sol-bundle.sh
          ! grep -F 'command -v uzdoom' tools/sol-run.sh
      - name: Validate v0.4 release contract
        run: |
          python3 - <<'PY'
          import json
          version = json.load(open('sol/version.json', encoding='utf-8'))
          manifest = json.load(open('sol/wadpack.json', encoding='utf-8'))
          defaults = json.load(open('sol/game/SOLDEFAULTS.json', encoding='utf-8'))
          assert version['version'] == '0.4.0'
          assert version['bundle_version'] == '0.4.0'
          assert version['editor_contract'] == '0.2.0'
          assert version['wadpack_contract'] == 3
          assert version['wadpack_entries'] == 18
          assert version['wadpack_slots'] == 20
          assert version['bundle_contract'] == 2
          assert version['runtime_slot'] == 21
          assert version['content_slot'] == 22
          assert version['soldefaults_contract'] == 1
          assert manifest['schema'] == 2
          assert manifest['wadpack_contract'] == 3
          assert manifest['active_entries'] == 18
          assert [x['slot'] for x in manifest['slots']] == list(range(1, 21))
          assert manifest['slots'][10]['state'] == 'retired'
          assert manifest['slots'][18]['id'] == 'precise-crosshair'
          assert manifest['slots'][19]['state'] == 'reserved'
          assert defaults['schema'] == 1 and defaults['contract'] == 1
          assert defaults['project'] == 'SOL'
          assert {'renderer', 'mod', 'audio', 'hud', 'gameplay'} == set(defaults['categories'])
          PY
          test -s THIRD_PARTY.md
          grep -F 'not a relicensing mechanism' THIRD_PARTY.md
          grep -F 'PreciseCrosshair v1.5.0' THIRD_PARTY.md
      - name: Validate native SOL v0.4 boot contract
        run: |
          grep -F 'set( ZDOOM_EXE_NAME "sol-engine"' CMakeLists.txt
          grep -F 'project(SOLEngine VERSION 0.4.0)' CMakeLists.txt
          grep -F '#define VERSIONSTR "0.4.0"' src/version.h
          grep -F '#define SOLPACK_SCHEMA 2' src/version.h
          grep -F '#define SOLBUNDLE_CONTRACT 2' src/version.h
          grep -F '#define SOL_WADPACK_CONTRACT 3' src/version.h
          grep -F '#define SOL_RUNTIME_SLOT 21' src/version.h
          grep -F '#define SOL_CONTENT_SLOT 22' src/version.h
          grep -F '#define SOLDEFAULTS_CONTRACT 1' src/version.h
          grep -F '{ 19, "wadpack", "precise-crosshair"' src/d_main.cpp
          grep -F '{ 21, "runtime", "sol-runtime"' src/d_main.cpp
          grep -F '{ 22, "content", "sol-content"' src/d_main.cpp
          grep -F 'does not retire SOLPACK slot 11' src/d_main.cpp
          grep -F 'does not reserve SOLPACK slot 20' src/d_main.cpp
          grep -F 'CCMD(sol_reset_defaults)' src/d_main.cpp
          grep -F 'SOL_ApplyCanonicalDefaults(false)' src/d_main.cpp
          grep -F 'D_AddFile(allwads, solbundle.GetChars()' src/d_main.cpp
          grep -F 'SOL_AllowProgressionWrite' src/sol/sol_run_state.cpp
      - name: Test bundle contract 2 and wadpack contract 3
        run: bash tests/test-sol-bundle-v04.sh
      - name: Test native development launcher
        run: bash tests/test-sol-launcher.sh
      - name: Validate story foundation
        run: bash tests/test-sol-story.sh
      - name: Package SOL-owned runtime component
        run: bash tools/sol-runtime-package.sh
      - name: Inspect runtime component and defaults
        run: |
          archive=$(find build/sol -maxdepth 1 -name 'sol-v0.4.0.pk3' -print -quit)
          test -n "$archive"
          unzip -t "$archive"
          unzip -Z1 "$archive" | grep -Fx ZSCRIPT
          unzip -Z1 "$archive" | grep -Fx MAPINFO
          unzip -Z1 "$archive" | grep -Fx SOLDEFAULTS.json
          unzip -p "$archive" SOLDEFAULTS.json | python3 -m json.tool >/dev/null
          unzip -Z1 "$archive" | grep -Fx zscript/sol/story_ids.zs
          unzip -Z1 "$archive" | grep -Fx zscript/sol/story_state.zs
          unzip -Z1 "$archive" | grep -Fx zscript/sol/bootstrap.zs
''', encoding="utf-8")


def main() -> None:
    patch_d_main()
    patch_cmake()
    write_bundle_test()
    write_workflow()
    (ROOT / "tools/sol-v04-apply.py").unlink()
    (ROOT / ".github/workflows/v04-apply.yml").unlink()


if __name__ == "__main__":
    main()
