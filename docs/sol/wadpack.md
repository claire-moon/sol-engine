# SOL locked wadpack

The authoritative SOL resource manifest and importer live in the sibling
`sol-editor` repository. `tools/sol-run.sh` delegates to the editor-side launch
contract so engine launches, editor playtests, and `sol-play` use the same local
eighteen-resource order.

Wadpack contract 2 preserves the original fourteen resources in positions 1–14
and appends Universal Ambience, CosmoAmbience Script edited, Ambient decorations,
and TargetSpy v3.1.0 in positions 15–18.

Third-party files are stored under sibling `vend/wadpack` and are not committed
to `sol-engine`. This is intentional: several items contain proprietary audio
or have redistribution terms requiring additional review. The three ambience
additions are marked review-required because the supplied PK3 files contain no
license/readme metadata; TargetSpy v3.1.0 identifies its main project license as
GPL-3.0-only.

The current implementation guarantees local presence, hashes, and load order.
Literal embedding into the executable is deferred until SOL owns or has
documented redistribution rights for every tuned resource.
