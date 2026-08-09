# Curated upstream intake

SOL Engine is derived from UZDoom, but `trunk` is a product branch rather than
a continuously rebased mirror. Upstream changes enter only through bounded,
reviewed intake branches.

## Intake policy

An upstream change is eligible when it is a security fix, correctness fix,
platform/build repair, measurable performance improvement, or a prerequisite
for an approved SOL roadmap item. General feature churn, branding/menu changes,
new game support, profile migration, updater behavior, and altered defaults are
not imported merely to match upstream.

Each intake records:

- upstream repository, commit, and release context;
- the concrete SOL reason for importing it;
- touched subsystems and expected behavior changes;
- licensing/provenance review;
- conflicts or SOL-specific adaptations;
- focused regression coverage and full platform results.

## Procedure

1. Fetch upstream without merging its default branch into `trunk`.
2. Create a bounded `upstream/intake-*` branch from current green `trunk`.
3. Apply the minimum relevant commits, preserving upstream attribution in the
   commit/PR record.
4. Audit SOL identity, profile isolation, IWAD restrictions, native `sol.pk3`
   ordering, modified-run rules, presentation defaults, and public packaging.
5. Add or update a regression test that fails without the intake.
6. Require exact-head SOL, Linux, Linux GCC, Windows MSVC/MinGW, macOS, and
   metadata checks appropriate to the affected code.
7. Squash-merge only after all required checks pass, then verify `trunk`.

Bulk merges, silent subtree updates, and automatic binary updates are outside
this process. Library subtree updates use the same review record and are pinned
to an explicit upstream revision.
