# [GPT-6-Astra] Audit — ARC-07a — cost and access control

## Verdict

**PASS WITH FINDINGS**

At **`66368ce`**, finding **1 is resolved**. Finding **2 is resolved in the lot’s documentation**, with the generated-header correction remaining a tooling follow-up. No new blocking finding was identified.

The revised recorded measurements support AC-3 exactly. Moving the held-list operations and prerequisite walk into the store preserves their recorded cost and access-control behavior.

## Findings

Closed findings retain their original severity.

| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | major — resolved | mock_store.cairo:431 (`packages/quest/tests/mock_store.cairo:431`), test_store_models.cairo:322 (`packages/quest/tests/test_store_models.cairo:322`) | **Definition tracking now has matched benchmarks demonstrating exact equality.** | Both arms use `DefinitionTrait::new`, identical slot conversion and identical storage writes. Silent store/hand costs are **1,497,390 each**; emitting store/hand costs are **1,652,490 each**. | None. |
| 2 | minor — resolved within scope | GAS.md:654 (`packages/quest/GAS.md:654`), BUDGETS.md:4 (`docs/BUDGETS.md:4`) | **Budget explanations now match the checker.** | All **510** budgets lie between the measurement and its rounded-up 5% ceiling; **34** are tighter than that ceiling, as documented. GAS.md explicitly qualifies the generated header’s remaining equality claim. | Correct the shared generator header in a separately scoped tooling change. No cap increases are needed. |
| 3 | note | Verification | **Fresh Cairo execution and CI remain independently unverified.** | Rebuilding and measuring require prohibited filesystem writes. The PR #20 GitHub API request failed to connect. | Confirm fresh tests, gas measurements and CI in the implementation environment. |

## Coverage

**AC-3, independently checked.** The definition benchmarks use identical dispatcher argument shapes and runtime calldata, the same model constructor, the same slot conversion, and the same A/B/C storage keys. The silent hand-written arm contains no event code. The emitting hand-written arm directly constructs the same event and uses the component’s emitter.

The raw GAS.md rows reconcile:

| Choice | Store test | Hand-written test | Matching baseline | Net cost, both arms |
|---|---:|---:|---:|---:|
| `TrackNone` | 1,838,200 | 1,838,200 | 340,810 | **1,497,390** |
| `TrackAll` | 1,993,300 | 1,993,300 | 340,810 | **1,652,490** |

The event increment is **155,100** in both arms. Destructuring the model snapshot once preserves event fields while removing the previously measured **400-gas** overhead.

I also reconciled the unchanged mechanism tests: constant, emitter and hand-written implementations each cost **454,530 silent** and **499,550 emitting**. Reporter comparisons remain exactly **454,630 silent** and **498,230 emitting**.

**Move into the store.** All six moved method bodies match their previous implementations after method renaming and the tuple-to-`HeldList` adaptation. Read order, early exits, whole-entry membership, kept bits and changed-slot write conditions remain intact. `HeldList` is an in-memory value, not a new storage layout.

The entire ABI/access-check section is **byte-for-byte unchanged**. Admin, reporter and player checks remain in their wrappers; the store methods introduce no external entrypoints. Completion, claim and retired-by-hook processing bodies are unchanged. Access, acceptance, claim, prerequisite and re-entry tests changed only their gas caps.

**Cost preservation.** Recomputed benchmark-minus-baseline costs:

| Call | Published 0.1.0 | Fix loop 1 | Change from previous audit |
|---|---:|---:|---:|
| Worst `progress_many`, H=4, created | 6,213,063 | 6,205,843 | 0 |
| Worst `progress_many`, H=8, created | 11,430,213 | 11,416,073 | 0 |
| Worst `accept` | 1,921,540 | 1,917,170 | 0 |
| Worst `abandon` | 574,060 | 564,150 | 0 |
| Worst `define` | 2,590,440 | 2,583,280 | **−400** |
| Worst `retire` | 1,003,240 | 1,003,540 | 0 |
| `claim` | 364,020 | 364,520 | 0 |

All **eight** progress combinations—H=4/8, created/existing, empty/writing hooks—are unchanged from the previous audit. Held-list and prerequisite views also retain their costs. The small retire/claim increases relative to published 0.1.0 remain within noise.

**Budgets and regression coverage.** All previous 501 tests remain, with nine additions. No existing recorded test cost or budget increased during this fix loop. The same three prerequisite-related caps remain the only increases against published 0.1.0, each retaining its explanatory note. All 510 source budgets match GAS.md; the 53 unambiguous benchmark/budget pairs checked in BUDGETS.md agree.

New tests cover definition rewrites and component action events under `TrackNone`. Packed models, storage declarations and interfaces are unchanged from the previous audit; its storage-layout conclusions and accepted 2³⁰ acceptance-identity residual remain applicable.

Formatting, Markdown links and diff-whitespace checks passed. No files were written, and no command remains running.