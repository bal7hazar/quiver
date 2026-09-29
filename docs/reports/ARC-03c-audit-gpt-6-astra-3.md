# [GPT-6-Astra] Audit — ARC-03c — security and cost

## Verdict

**FAIL**

At **`10f46d9`**, the original counterexample in finding **2 is resolved**, finding **3 is resolved under the orchestrator’s verification decision**, and finding **4 is partially resolved**.

The fix introduces **finding 6: valid progress can be permanently lost**. The documented false exclusion is not merely a delay: the skipped batch is never retained or replayed.

## Findings

Closed findings retain their original severity.

| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 2 | major | component.cairo:547 (`packages/quest/src/component.cairo:547`) | **Resolved for the reported renewal counterexample.** | With start counter 1 and renewed Q2 numbered 2, the modular window excludes Q2 before either membership check can accept its identical tuple. The new regression reproduces the reachable prehistory and checks that the next call progresses Q2. | Retain this regression while addressing finding 6. |
| 3 | major | test_component_writes.cairo (`packages/quest/tests/test_component_writes.cairo:1`), GAS.md:692 (`packages/quest/GAS.md:692`) | **Resolved under the stated cost-focused verification decision.** | The limitation is explicit; both missing fixtures exist. Six recorded call-write counts are **2, 1, 1, 2, 1, 2**, after subtracting seven setup writes. Source inspection agrees. Gas guards detect uncompensated extra writes but intentionally permit compensated changes. | No further fix required for this finding. Preserve the distinction between automated gas guards and manually recorded syscall counts. |
| 4 | minor | GAS.md:648 (`packages/quest/GAS.md:648`), BUDGETS.md:113 (`docs/BUDGETS.md:113`) | **Partially resolved:** one contradictory count remains. | Saturated claim now correctly says **2 writes, 1 changed slot**, but also says **1 overwritten**. Both documents define overwrites to include unchanged rewrites, so P and R count as **2 overwritten slots**. Reporter revocation and the held-list-only never-zeroed statement are corrected. | Replace “1 overwritten” with “2 overwritten; only P changes.” |
| 5 | note | Verification | **Runtime and CI remain independently unverified.** | Build/tests and fresh resource measurements require prohibited writes. GitHub API access failed. | Confirm the revised suite, resource measurements and CI in the implementation environment. |
| 6 | major | component.cairo:550 (`packages/quest/src/component.cairo:550`), GAS.md:513 (`packages/quest/GAS.md:513`) | **New defect: accepting another quest can discard a continuously held quest’s legitimate progress.** | Start with Q1 numbered 1, Q2 numbered 2, counter 1—the existing reachable prehistory. Q1 completes; its hook **accepts Q3**, issuing number 2, without abandoning Q2. Q2 remains live and held, but its number falls in the issued window and it is skipped. No pending batch is stored. | Distinguish actual acceptance instances or track which entries were renewed during active calls. Add a regression where the hook accepts another quest whose number collides with an unchanged entry. Preserve the renewal protection from finding 2. |

## Coverage

Reviewed fix loop 3 against the audit brief from `origin/main`, the implementation brief, Cairo rules, amended specification, implementation report and previous findings. Finding 1 remains closed.

**Modular arithmetic and read ordering.** The calculation correctly handles windows crossing zero. For example, start `65534`, current `1` excludes precisely `65535`, `0`, and `1`. Independent integer checks passed **3,145,660 boundary cases**, covering every `u16` start value.

The interval is correct for fewer than 65,536 acceptances during the call. A complete counter cycle would alias to zero, so protection still relies on the transaction resource bound.

`held_entries_from` captures the counter from the same initial slot-0 read used for the list, before any completion hook. It preserves the existing termination rules and four-slot bound. Empty batches and event mode return before this read.

Checking the window **before** positional equality and fallback membership is necessary to block the original reused-tuple counterexample. Moving equality ahead would reopen finding 2. The problem in finding 6 is that a number alone cannot identify which quest was renewed.

**The residual loses counts.** The implementation brief requires applying the batch to every live, currently accepted quest. In the new counterexample, Q2 satisfies those conditions throughout.

With Q2’s target set to 10, an initial batch reporting three counts is skipped after Q1’s hook accepts Q3. A later batch reporting one count leaves Q2 at **1 instead of 4**. The earlier three counts are gone. This was reproduced in an in-memory transition model, including a variant where the counter wraps from `65535` to `0` inside the call.

The existing “without renewal” regression has no acceptance inside the hook, so it does not test this collision. Documenting the residual does not make it conform to the brief.

**Finding 3’s decision.** I accept the orchestrator’s choice as a verification tradeoff consistent with the rule’s cost purpose. The brief preserves one write per record but does not prescribe a particular automated syscall-count mechanism. The implementation still meets that structural rule, the six fixtures have recorded resource counts, and the automated guards bound execution cost.

This closes the testing finding without claiming that gas proves an exact write count. The documented counts remain manual evidence, not an automatic invariant.

**Costs.** All eight principal benchmark-minus-baseline calculations and network estimates reconcile:

| Held / hooks | Created P/R: snforge / network estimate | Existing P/R: snforge / network estimate |
|---|---:|---:|
| 4 / empty | 6,292,283 / 6,247,435 | 3,076,283 / 2,875,435 |
| 4 / one new hook slot | 8,107,203 / 8,039,931 | 4,891,203 / 4,667,931 |
| 8 / empty | 11,676,993 / 11,587,297 | 5,244,993 / 4,843,297 |
| 8 / one new hook slot | 15,306,833 / 15,172,289 | 8,874,833 / 8,428,289 |

The additional reads explain the increase to **25 reads at H=4** and **50 at H=8**. These recorded fixtures remain below 20M.

Reporter revocation correctly reconciles as **−194,470 + 402,000 = 207,530** standalone snforge gas, with network estimate **182,424**. Network repricing remains arithmetic based on the supplied slot prices, not independently measured network execution.

One secondary cost summary also remains stale: ARC-01:1560 (`docs/research/ARC-01-quest-achievement.md:1560`) still states one additional post-hook read and a 1.298M completing-quest bound. The revised path can read two slots after a hook; the updated grid reaches approximately 1.334M per quest after subtracting its fixed baseline. Update that summary alongside finding 4.

**Other checks.** No additional access-control, packing, kept-slot, claim or retirement defect was found. All **417 tests** have matching recorded budgets exactly equal to `ceil(1.05 × recorded gas)`; none is ignored. All 69 named cases remain represented.

Formatting, Markdown links and diff-whitespace checks passed. No files were written. All commands finished in the foreground; nothing remains running.