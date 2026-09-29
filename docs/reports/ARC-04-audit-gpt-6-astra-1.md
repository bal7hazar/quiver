# [GPT-6-Astra] Audit — ARC-04 — security and cost

## Verdict

**PASS WITH FINDINGS** at `33f674c`.

No blocker, major, access-control bypass or unintended storage-mode path found. Two minor corrections remain. Under OPERATIONS §6, they require fixes or explicit deferral before merge.

Runtime gas measurements and CI remain independently unverified under this audit’s restrictions.

## Findings

| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | minor | test_packing.cairo:152 (`packages/achievement/tests/test_packing.cairo:152`) | The bit-251 rejection test does not exercise bit 251. | `achievement_unpacking_rejects_bit_251` supplies `2^251 − 1`: bit 251 is clear, and lower reserved bits cause rejection. A decoder that discarded bit 251 could still pass this test. The current decoder appears correct. | Supply exactly `2^251` as a felt, bypassing the test helper that requires values below `2^251`. Refresh its gas budget. |
| 2 | minor | Scarb.toml:8 (`packages/achievement/Scarb.toml:8`) | Publication metadata still advertises claiming. | The inherited description says “tasks, tiers, claim,” while this release deliberately has no claim functionality. | Describe event-only progress and indexer-derived tiers. |
| 3 | note | Verification | Recorded measurements reconcile, but fresh execution and CI were unavailable. | No compiled artifacts exist in this checkout; building/tests would write files. `gh pr checks 17` failed connecting to `api.github.com`. | Confirm build, full tests, detailed resources, `gas.py --check`, and green CI in the implementation environment. |

## Coverage

**Access control.** All five `IAchievement` entrypoints have the expected checks and meaningful negative tests. Non-admins—including registered reporters—cannot define, retire or change reporters. Both progress methods check current reporter membership before processing input; revocation applies on the next call. Admin status alone does not authorize progress.

The internal implementation is not embeddable as an external ABI. The consumer-only mock tests all five external selectors for `ENTRYPOINT_NOT_FOUND`. Consumers can deliberately expose internal calls, and their responsibility to authorize those calls is documented. Reporters can report arbitrary players and tasks, but gain no administrative capability.

**Event-only conformance.** Production storage contains only definitions, extra tasks and reporter membership. There is no `Mode`, player record, task-page index, completion/claim entrypoint or completion hook. No storage member or bit is assigned to the future counter design. README and amended ARC-01 §§3.10–3.11 explicitly describe that absence.

**Definitions and packing.** Validation rejects ID zero, task counts outside 1–3, zero task IDs or totals, repeated tasks and invalid closed windows. Defined IDs cannot be reused, including after retirement. Retirement requires an existing, unretired definition and preserves its remaining fields.

Slot A occupies 196 bits; slot B occupies 128 bits. Their maxima are respectively `2^196 − 1` and `2^128 − 1`, both below `2^251`. The narrowed task-count field is checked; decoders reject reserved bits. Zero decodes as undefined; presence bits are at 130 and 131. One-task definitions use one slot; two or three tasks require two. All four events have field/key assertions.

**Progress.** The 16-entry limit is checked before merging, including duplicates and zeros. Duplicate counts saturate at `u32::MAX`; zero sums disappear; task zero is rejected on both merge paths. Output preserves first-occurrence order and emits exactly one event per merged nonzero task. Internal progress performs no storage access; external progress adds one reporter read.

Emitting for unused or retired tasks is **acceptable for 0.1.0**: it follows the event-only decision, avoids definition-dependent cost, is explicitly documented, and has a regression test. The indexer applies windows, retirement and tier thresholds.

**Cost.** Recorded benchmark-minus-baseline arithmetic reconciles:

| Case | Recorded call L2 gas | Network estimate |
|---|---:|---:|
| Worst late-collision `progress_many`, 16 events | 1,816,813 | 1,816,813 |
| Late-duplicate `progress_many`, 15 events | 1,759,993 | 1,759,993 |
| Three-task definition | 1,197,030 | 1,185,818 |
| Game results: six character tasks plus two account tasks | 829,728 | 829,728 |
| Game’s 16-task batch | 1,245,286 | 1,245,286 |
| All 26 title-tier definitions together | 18,525,730 | 18,379,974 |

The game fixture represents all eight MVP titles and their 26 tiers. The worst recorded progress call uses **9.1%** of the cap and does not grow with achievement definitions.

The README’s bulk-definition advice is **adequate**: it identifies the 92.6% setup cost, recommends splitting transactions, and explicitly includes consumer/account overhead. Its approximate batch sizes are guidance, not guaranteed transaction limits. Benchmarks use a permissive admin hook, so real authorization overhead remains the consumer’s responsibility.

**Tests and checks.** All **102 source tests** have matching GAS.md rows, no ignored tests, and budgets exactly `ceil(1.05 × recorded gas)`. This verifies recorded consistency, not fresh measurements. Kept named cases contain substantive assertions; dropped cases depend on removed storage, completion, claim, mixed-mode or task-page behavior.

Read-only verification passed:

- Achievement formatting, Markdown links and diff-whitespace checks.
- Independent Python models: 20,000 definition round trips, rejection of all 56 reserved A bits, power-table validation, and 20,000 batch comparisons against an oracle.

These models supplement source review; they are not Cairo execution.

No files were written. All commands finished in the foreground; nothing remains running.