# [GPT-6-Sol] Audit — ARC-01 — design and quality

## Verdict

**PASS WITH FINDINGS.** All five open findings are resolved. Before accepting `MAX_ENTRIES = 16` at A-G1, the owner needs to confirm that one expedition cannot report more than 16 distinct quest tasks.

## Findings

| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 2 | Resolved | §3.1 (`docs/research/ARC-01-quest-achievement.md:572`) | The second-call fallback is gone. | The consumer aggregates by task id and makes one `progress_many` call per player per transaction; an oversized list reverts. | None. |
| 3 | Resolved | §3.5 (`docs/research/ARC-01-quest-achievement.md:1005`) | Retirement preserves prerequisite and acceptance semantics. | `define` increments each distinct prerequisite’s `live_dependents`; retiring the dependent decrements it. A prerequisite with live dependents cannot be retired. Acceptance views return false for retired quests. | None. |
| 10 | Resolved | Batch algorithm (`docs/research/ARC-01-quest-achievement.md:678`) | The first-position check no longer needs A before reading B. | It reads B’s task slots; task id 0 marks unused slots and is rejected as input. | None. |
| 11 | Resolved | §5 (`docs/research/ARC-01-quest-achievement.md:1495`) | The cost witnesses are reachable. | They use quests without an accept step whose prerequisites were met earlier but have not yet been cached as unlocked. The stated 340-read single-task and 5,440-read batch totals follow from those witnesses. | None. |
| 12 | Resolved | Packed layouts (`docs/research/ARC-01-quest-achievement.md:775`) | Completion and claim counters are `u64` and saturate. | QuestDefinition A occupies 216 bits; QuestRecord occupies 194 bits, including the `u64` interval id. The fields do not overlap and fit a `felt252`. | None. |
| 13 | Major | Q-19 (`docs/research/ARC-01-quest-achievement.md:1715`) | The recommended batch bound may reject a valid expedition. | Q-19 estimates **12–19** distinct quest tasks for a long expedition, recommends **16**, and removes the second-call fallback. A 17-task result would revert. The document correctly raises this as a game decision, but A-5’s “Covered” claim (`docs/research/ARC-01-quest-achievement.md:1442`) depends on its answer. | At A-G1, establish a game-enforced ceiling of 16 or choose a bound that covers the confirmed maximum; update the cost figures if the bound changes. |
| 14 | Minor | Q-14 (`docs/research/ARC-01-quest-achievement.md:1710`) | Its retirement cost is stale. | Q-14 says at most 14 reads and 7 writes; the revised §5 table (`docs/research/ARC-01-quest-achievement.md:1502`) correctly allows 22 reads and 14 writes after prerequisite-counter updates. | Change Q-14 to 22 reads and 14 writes. |

## Coverage

Rechecked the five open findings, the changed define and retire paths, the task-id sentinel, packed bit widths, and the revised cost witnesses and tables against the audit brief. The `live_dependents` updates have no apparent reachable underflow or missed decrement under the stated definition and retirement rules. This was a document audit; no files were changed and no code was run.