# [GPT-6-Astra] Audit — ARC-06 — cost

## Verdict

**PASS WITH FINDINGS.** No cost regression found in the recorded measurements. One minor benchmark issue affects the interpretation of absolute read costs; it does not invalidate the hand/store comparisons or the claimed write savings.

Audited PR #19 checkout at `5b3d73f`.

## Findings

| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | minor | test_store.cairo:136 (`packages/quest/tests/test_store.cairo:136`), test_store_definition.cairo:137 (`packages/quest/tests/test_store_definition.cairo:137`) | Read baselines do not isolate the advertised read cost. | The baselines call write-shaped `noop` functions, passing three scalars or an entire definition and returning nothing. Read benchmarks pass only an ID, deserialize a result and assert it. Thus **32,590**, **69,240** and **69,210** include unmatched harness/ABI costs. Hand/store equality and the −30 difference remain valid because both comparison arms share those costs. | Add read-specific baselines with matching arguments, return shape and assertions; regenerate the absolute figures. |
| 2 | note | store.cairo:37 (`packages/quest/src/store.cairo:37`), research:237 (`docs/research/ARC-06-model-store.md:237`) | ARC-07 must preserve selective reads and reuse slot A. | `get_definition` reads B and, with conditions, C. Replacing A-only schedule/status reads with it would add unnecessary storage reads and span construction. The proposed view composition, `get_definition` plus a separately loaded status model, would read A twice. `progress_held` currently postpones B until after its early exits and never needs C. | Provide selective store methods and conversion from an already-loaded A. Preserve early exits; benchmark the composed view before adopting it. |
| 3 | note | component.cairo:160 (`packages/quest/src/component.cairo:160`), component.cairo:511 (`packages/quest/src/component.cairo:511`) | ARC-07 must distinguish model writes from action events. | Prerequisite counters currently change without events; partial progress writes P without emitting `QuestCompleted`. Tracking these models with those events would introduce emissions on previously silent paths. Tracking both progress and record could also duplicate completion emissions. ARC-06 itself avoids this regression. | Keep those storage models untracked where necessary and retain action-specific emission. Test event counts on partial progress, prerequisite updates, completion and claim. |

## Coverage

Reviewed the specification, research claims, `GAS.md`, `BUDGETS.md`, CAIRO §1–§6, production changes, new model/store tests and existing component benchmarks.

- **Mechanism:** matching hand/store arms use identical keys, values and storage members. Overwrite cases seed nonzero slots using the cheatcode. Inputs cross contract dispatchers, preventing caller constants from folding away the storage operations. Recorded hand/store differences are **zero** for all four write cases and the one-slot read. The tracked-write increment is **45,020**, for the tested event payload.
- **Definition savings:** independently recomputed **4,560** for the three-slot write and **6,760** for the worst measured `define`, using their respective baselines.
- **Selective reads:** source confirms `has_definition` reads A alone; `get_definition` reads A alone when absent, A+B without conditions, and A+B+C otherwise. Behavior tests exercise these cases, but there are no isolated syscall-count checks for each branch.
- **Regression comparison:** checked all **42 component benchmark/baseline pairs** against the published `quiver_quest-v0.1.0` tag. Only `define` changes, from **2,590,440 → 2,583,680**. The largest documented benchmark call remains **15,060,053 L2 gas**, leaving **4,939,947** below the 20M cap.
- **Budgets:** all **470** source tests have matching table entries and budgets exactly equal to `ceil(1.05 × measured)`. Of the **423** pre-existing tests, 192 have lower recorded costs and 231 are unchanged. No budgets increased; existing test-body changes are limited to budget attributes.
- **Measurement evidence:** the implementer’s saved full snforge log reports **470 passed**, and every measurement matches the audited table. This was a read-only reconciliation, **not an independent test rerun**. Building/running the suite would write artifacts. Live CI verification was unavailable: `gh pr checks 19` failed to connect to GitHub.

No files were written.