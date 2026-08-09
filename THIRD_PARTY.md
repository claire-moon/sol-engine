# SOL third-party resources

SOL's canonical third-party resource inventory is moving into this repository
under wadpack contract 3. The generated `sol.pk3` preserves every normalized
third-party WAD/PK3 byte-for-byte inside a native embedded-resource carrier and
includes this `THIRD_PARTY.md` inside the bundle.

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
| 11 | HQ PSX music | retired/unmounted by wadpack contract 3 |
| 12 | PlayStation sound effects | local-only development placeholder pending original SOL replacement |
| 13 | Flashlight++ 9.1 | review-required |
| 14 | WW Alpha HUD | review-required |
| 15 | Universal Ambience | upstream distribution lists GPL; third-party audio assets require review |
| 16 | CosmoAmbience Script edited | GPL-listed upstream component; supplied local edited variant requires modification/source provenance and audio review |
| 17 | Ambient decorations | upstream distribution lists GPL; third-party audio assets require review |
| 18 | TargetSpy v3.1.0 | GPL-3.0-only, © 2026 Alexander Kromm (mmaulwurff) |
| 19 | PreciseCrosshair v1.5.0 | main project GPL-3.0-only; bundled libeye carries `LicenseRef-libeye`; preserve upstream REUSE/license notices and review before public redistribution |
| 20 | Reserved | intentionally unmounted |

## Recorded source pages

- Universal Ambience package and credits: https://www.moddb.com/addons/universal-ambience
- TargetSpy v3.1.0 license: https://mmaulwurff.github.io/doom-toolbox/add-ons/TargetSpy.html
- FinalCustomDoom license: https://mmaulwurff.github.io/doom-toolbox/add-ons/FinalCustomDoom.html
- PreciseCrosshair project: https://github.com/mmaulwurff/precise-crosshair
- NashGore NEXT project: https://www.moddb.com/mods/nashgore-next
- Voxel Doom 2.4 release: https://www.moddb.com/addons/voxel-doom-ii-with-parallax-textures

The Universal Ambience page credits McTed, Heydoomer, Agent Ash, Boondorl,
Dr_Cosmobyte, and multiple external sound sources. TargetSpy declares
GPL-3.0-only and © 2026 Alexander Kromm. PreciseCrosshair v1.5.0 was supplied
for the SOL local wadpack with SHA-256
`c2c958b04e53013e4ba49707d74529178800f9d754dc4c677201e5754dc9ef94`.
Its package identifies the main project as GPL-3.0-only and separately preserves
the bundled libeye notice/license plus REUSE metadata. Those notices remain
part of the unmodified upstream archive and must be retained.

## Native bundle behavior

The physical `sol.pk3` uses numbered root-level `.wad` carrier names. Those
suffixes trigger the inherited embedded-resource handling; the contained bytes
remain the original normalized WAD/PK3 archives and are opened by file content.
SOL Engine v0.3.0 mounts adjacent `sol.pk3` natively. v0.4.0 bundle contract 2
keeps numeric slot identity explicit so retired/reserved positions can remain
unmounted without renumbering later resources.

## Distribution boundary

The complete `sol.pk3` remains a local development/test build artifact. Credits
and preserved upstream notices do not create permission to redistribute
proprietary or otherwise uncleared assets. Public binary publication remains
blocked until the third-party audit is complete.
