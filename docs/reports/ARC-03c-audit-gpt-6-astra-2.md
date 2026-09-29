# [GPT-6-Astra] Audit — ARC-03c — security and cost

## Verdict

**FAIL**

At **`217cd43`**, finding **1 is resolved**, **2 remains unresolved**, and **3–4 are partially resolved**.

The acceptance counter can reuse an outstanding entry’s number after wrap-around across **earlier transactions**. Renewing that entry from a hook then defeats `still_held`. The report’s argument that a collision requires 65,536 acceptances within one call is incorrect.

No additional authorization bypass, duplicate claim, or kept-slot packing defect was found.

## Findings

Severities 1–4 retain their original classifications.

| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | major | GAS.md (`packages/quest/GAS.md:429`), docs/BUDGETS.md | **Resolved:** allocation and overwrite costs are distinguished. | Separate probes cover creation, updates, unchanged writes, clears and restorations. Blanket allocation surcharges were removed. Created/existing progress fixtures, mixed-list acceptance and growth/regrowth benchmarks are present. Baseline subtraction and network repricing reconcile with the recorded figures. | None for the original finding. Remaining documentation inaccuracies are covered by finding 4. |
| 2 | major | component.cairo:332 (`packages/quest/src/component.cairo:332`), `still_held` at line 534 | **Unresolved:** wrapping acceptance numbers still permit renewed acceptance to match the outer snapshot. | Hold Q1 with number 1 and Q2 with number 2. Across earlier transactions, accept/abandon Q3 65,535 times: the counter becomes 1 while Q2 retains number 2. Q1’s completion hook abandons and reaccepts Q2; its new number is again 2. `still_held` accepts the identical tuple, allowing Q2 to complete from the earlier batch. | Use an acceptance identity scheme that cannot reuse an outstanding identity, including after lifetime counter wrap. Add a regression seeded with this reachable prehistory. Correct the report’s within-one-call argument. |
| 3 | major | test_component_writes.cairo (`packages/quest/tests/test_component_writes.cairo:3`) | **Partially resolved:** useful gas guards were added, but they do not assert write counts. | An uncompensated extra write exceeds the 20,000 tolerance. However, adding 58,820 gas of writes while saving 40,000 elsewhere changes total gas by only 18,820 and passes that assertion. The injected-write experiment tests only the uncompensated case. The new fixtures also omit the two-task **noncompleting** case; their duplicate fixture has only one positive count. | Automatically assert storage-write resource counts, excluding hooks. Retain the gas guards and add noncompleting multi-task and multiple-positive-duplicate fixtures. Qualify the claim that any extra write necessarily fails. |
| 4 | minor | GAS.md:611 (`packages/quest/GAS.md:611`), BUDGETS.md:109 (`docs/BUDGETS.md:109`), README.md | **Partially resolved:** `define` counts are corrected, but writes and changes are still conflated. | Saturated `claim` unconditionally writes **both P and R** at component lines 380–381. Only P changes, but the table says “1 overwritten” while defining overwrites to include unchanged rewrites. Also, `set_reporter(existing, false)` writes zero, contradicting “No entrypoint zeroes a slot” and “The package never zeroes a slot.” | State saturated claim as **2 writes/overwrites, 1 changed slot**. Include reporter revocation and restrict the never-zeroed statement to held-list slots. |
| 5 | note | Verification | **Runtime and CI verification remain incomplete.** | Cairo tests and fresh gas measurements require prohibited filesystem writes. GitHub API access failed. | Independently rerun the suite, gas checks and PR checks in the implementation environment after corrections. |

## Coverage

Re-audited the revisions against the brief read from `origin/main`, D-135 and its pricing correction, the implementation brief, Cairo rules, earlier audits, and both implementation-report fix loops.

**Acceptance numbers and re-entry.** The ordinary renewal regression is fixed: equality now includes `(quest_id, interval_id, acceptance)`, including the fallback scan after compaction. The counter is preserved through abandonment and pruning, stored in slot 0, and written as zero in other slots. Acceptance number zero is valid after wrapping; emptiness correctly depends on quest ID.

`quest_is_accepted` correctly matches quest and current interval without requiring a particular acceptance number, then excludes completed quests. Its ordinary semantics remain correct.

The wrap counterexample was reproduced in an **in-memory model of the source transitions**, including the 65,535 earlier acceptance/abandonment cycles. After Q1 completes and its hook renews Q2, acceptance prunes Q1 and moves Q2. The fallback scan still returns true for the renewed tuple. This requires the described consumer hook; it is not an authorization bypass. Existing renewal tests do not exercise this boundary.

**Kept slots and packing.** No defect found:

- Fields occupy distinct ranges through bit 240; packed values remain below `2^241`. Unpacking rejects reserved bits 241 and above.
- Both list readers stop at an empty quest ID, including a kept-only slot.
- `still_held` cannot mistake a kept-only slot for a valid snapshot entry.
- Shrink, pruning and regrowth preserve markers and contiguous entries. The marker also keeps slot 0 nonzero when its counter wraps to zero.

Independent integer checks passed **10,000 packing round trips** and **6,882 prune/accept/abandon transitions** across capacities 1–8. These checks did not execute Cairo.

**Write assertions.** The new guards are materially stronger than whole-test budget headroom, and source inspection still finds one P write per changed quest plus one R write on completion. Their limitation is the oracle: total Sierra gas cannot distinguish writes from other execution work. The reported injected-write failures support the narrow regression check, not an exact write-count guarantee.

**Cost and network estimates.** All eight principal progress cases reconcile with the recorded benchmark-minus-baseline values:

| Held quests / hooks | Created P/R: snforge / network estimate | Existing P/R: snforge / network estimate |
|---|---:|---:|
| 4 / empty | 6,182,583 / 6,137,735 | 2,966,583 / 2,765,735 |
| 4 / one new hook slot | 7,997,503 / 7,930,231 | 4,781,503 / 4,558,231 |
| 8 / empty | 11,374,333 / 11,284,637 | 4,942,333 / 4,540,637 |
| 8 / one new hook slot | 15,004,173 / 14,869,629 | 8,572,173 / 8,125,629 |

The fixtures retain the late-collision batch, three late-position tasks, and completion of every held quest. Existing-state fixtures seed P/R; hook slots remain fresh.

Network arithmetic correctly applies:

`estimate = recorded call − 5,606 × created − 25,106 × overwritten`

The game case reconciles at **4,522,926 / 4,439,078**, with six created and two overwritten slots. Acceptance growth reconciles at **1,899,210 / 1,862,892**, with two created and one overwritten.

These are **recorded snforge measurements and conditional network estimates**, not independently reproduced transaction measurements. They remain below 20M for the specified fixtures. Account execution, additional consumer work and more expensive hooks remain outside those figures.

**Remaining security and test coverage.** Access checks, player isolation, prerequisites, retirement guards, completion/claim ordering and earlier ARC-03a/03b fixes remain intact. `quest_held` deliberately returns unpruned stale entries, as documented. Keeping acceptance solely in the held list remains a reasonable design.

All **408 tests** have matching GAS.md entries and budgets exactly equal to `ceil(1.05 × recorded gas)`; none is ignored. All **69 named cases** remain represented through 68 exact names and the packing-test family. Presence does not close findings 2–3.

Formatting, Markdown links and diff-whitespace checks passed. No files were written. All commands finished in the foreground; nothing remains running.