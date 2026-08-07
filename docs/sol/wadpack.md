# SOL locked wadpack

The authoritative SOL resource manifest and importer live in the sibling
`sol-editor` repository. `tools/sol-run.sh` delegates to the editor-side launch
contract so engine launches, editor playtests, and `sol-play` use the same local
fourteen-resource order.

Third-party files are stored under sibling `vend/wadpack` and are not committed
to `sol-engine`. This is intentional: several items contain proprietary audio
or have redistribution terms requiring additional review.

The current implementation guarantees local presence and load order. Literal
embedding into the executable is deferred until SOL owns or has documented
redistribution rights for every tuned resource.
