# SOL third-party resources

SOL's canonical third-party resource inventory is shared with the sibling
`sol-editor` repository. The generated `sol.pk3` preserves every normalized
third-party WAD/PK3 byte-for-byte inside a native embedded-resource carrier and
includes the complete editor-side `THIRD_PARTY.md` inside the bundle.

This inventory is attribution/provenance, not a relicensing mechanism. The SOL
project license does not relicense third-party content. Public redistribution is
not cleared until every resource and bundled asset has a documented grant and
all applicable notice/source obligations are satisfied.

| # | Component | Recorded status |
|---:|---|---|
| 1 | Voxel Doom 2.4 | code reported GPLv3; graphics/assets require separate review |
| 2 | Universal Weapon Sway 1.0 | MIT |
| 3 | Troo Cullers 2.5 | review-required |
| 4 | Tilt++ | BSD-3-Clause |
| 5 | Relighting 0.7.3b | review-required |
| 6 | Angled Doom Lite 1.2.1 | permission-included; review required |
| 7 | NashGore NEXT | Nash Muhandes; redistribution terms require review |
| 8 | NashGore official voxels | Cheello and Nash Muhandes; redistribution terms require review |
| 9 | Final Custom Doom 1.0.0 beta | GPL-3.0-only, © 2025 Alexander Kromm |
| 10 | Vanilla Essence 4.3 | review-required |
| 11 | HQ PSX music | accidental local input still mounted by transitional contract 2; ordered retired/unmounted in wadpack contract 3 |
| 12 | PlayStation sound effects | local-only development placeholder pending original SOL replacement |
| 13 | Flashlight++ 9.1 | review-required |
| 14 | WW Alpha HUD | review-required |
| 15 | Universal Ambience | upstream distribution lists GPL; third-party audio assets require review |
| 16 | CosmoAmbience Script edited | GPL-listed upstream component; supplied local edited variant requires modification/source provenance and audio review |
| 17 | Ambient decorations | upstream distribution lists GPL; third-party audio assets require review |
| 18 | TargetSpy v3.1.0 | GPL-3.0-only, © 2026 Alexander Kromm (mmaulwurff) |

## Recorded source pages

- Universal Ambience package and credits: https://www.moddb.com/addons/universal-ambience
- TargetSpy v3.1.0 license: https://mmaulwurff.github.io/doom-toolbox/add-ons/TargetSpy.html
- FinalCustomDoom license: https://mmaulwurff.github.io/doom-toolbox/add-ons/FinalCustomDoom.html
- NashGore NEXT project: https://www.moddb.com/mods/nashgore-next
- Voxel Doom 2.4 release: https://www.moddb.com/addons/voxel-doom-ii-with-parallax-textures

The Universal Ambience page credits McTed, Heydoomer, Agent Ash, Boondorl,
Dr_Cosmobyte, and multiple external sound sources. TargetSpy declares
GPL-3.0-only and © 2026 Alexander Kromm. The complete detailed credit notes,
source hashes, and local-edited-variant warning are maintained in the sibling
`sol-editor/THIRD_PARTY.md` and `sol-editor/sol-project/wadpack.json`.

## Native bundle behavior

The physical `sol.pk3` uses numbered root-level `.wad` carrier names. Those
suffixes trigger the inherited embedded-resource handling; the contained bytes
remain the original normalized WAD/PK3 archives and are opened by file content.
SOL Engine v0.3.0 mounts adjacent `sol.pk3` natively, which mounts the complete
stack in 01→20 order without a wrapper-supplied `-file` argument.

## Distribution boundary

The complete `sol.pk3` remains a local development/test build artifact. Credits
and preserved upstream notices do not create permission to redistribute
proprietary or otherwise uncleared assets. Public binary publication remains
blocked until the third-party audit is complete.
