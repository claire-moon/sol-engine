# SOL Fixed Mod Stack

SOL v0.1.0 requires the following local third-party archives in this exact load order:

1. `PSSFX.zip`
2. `flashlight_plus_plus_v9_1.7z`
3. `FinalCustomDoom-v1.0.0-beta.pk3`
4. `jdra-Angled-Doom-Lite-1.2.1.pk3`
5. `TrooCullers2.5.pk3`
6. `TiltPlusPlus.pk3`
7. `Universal-Weapon-Sway-master.zip`
8. `nashgore_next.zip`

The canonical machine-readable list is `sol/mods/stack.txt`. Do not reorder, rename, omit, or silently substitute files.

## Local layout

By default the resolver reads the archives from the sibling workspace directory:

```text
vend/sol-mods/
```

`SOL_MOD_ROOT` may point to another local directory. `tools/sol-mod-stack.sh --check` validates that all eight exact files are present. No third-party mod archive is downloaded or redistributed by this repository.

## Runtime order

`tools/sol-run.sh` launches content in this order:

```text
IWAD -> fixed SOL mod stack -> SOL runtime package -> authored SOL map/content package
```

The fixed stack is mandatory. The SOL runtime package follows the third-party stack so SOL-owned definitions can establish the project contract. Editor-authored content follows the runtime package when launched by `sol-editor`.

## Provenance

Before any third-party archive is embedded into a distributed SOL binary or release package, its license and redistribution terms must be recorded and approved. Until then the v0.1.0 repository integration treats these archives as required local vendor inputs.
