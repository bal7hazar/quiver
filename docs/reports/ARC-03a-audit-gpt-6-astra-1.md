# [GPT-6-Astra] Audit — ARC-03a — correctness and cost

## Verdict

**FAIL**

Packing violates the audit’s field-isolation and malformed-value requirements. The batch benchmarks also omit a more expensive reachable execution path.

These packing failures involve directly constructed or malformed values; I found no path from `definition_new` through the specified component workflow that produces them.

## Findings

| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | major | types.cairo:128 (`packages/quest/src/logic/types.cairo:128`) | Definition counts can corrupt neighboring fields. Public `u8` fields exceed their packed widths without validation. | With other fields zero, `task_count = 4` round-trips as `task_count = 0, condition_count = 1`. `condition_count = 16` sets `defined = true`. Existing maximum tests stop at 3 and 7. | Reject counts outside their packed ranges and add regression tests. Escalate the specification conflict: unrestricted `u8` round-trips cannot coexist with two-/three-bit layouts. |
| 2 | major | types.cairo:237 (`packages/quest/src/logic/types.cairo:237`) | Page packing and unpacking accept lengths exceeding seven, violating the layout and the component’s page invariant. | `unpack(2^227)` returns `len = 8`. `page_span` then returns seven entries, while `page_pop` panics when clearing position 7. `pack` also accepts `len = 255`, occupying eight length bits instead of three. | Check `len <= QUESTS_PER_PAGE` on packing and reject decoded lengths above seven. Test malformed felts and lengths 8 and 255. |
| 3 | minor | types.cairo:258 (`packages/quest/src/logic/types.cairo:258`) | Progress unpacking treats every bit above bit 96 as part of `claimed`, rather than reading bit 97 alone. | `unpack(2^98)` returns `claimed = true`, although bit 97 is zero; repacking produces `2^97`. The input is outside the image of valid progress packing and silently changes meaning. | Reject values outside the 98-bit encoding, or explicitly define and test safe handling of reserved bits. |
| 4 | minor | test_bench.cairo:43 (`packages/quest/tests/test_bench.cairo:43`), batch.cairo:50 (`packages/quest/src/logic/batch.cairo:50`) | Batch benchmarks do not establish worst-case cost. | The eight-pair benchmark performs 64 merged-list comparisons and 92 suffix comparisons. Positive-count IDs `[1,…,15,15]` perform 120 of each and delay fast-path failure until entry 16. `[1,…,15,129]` additionally demonstrates a late modulo collision with all IDs distinct. | Benchmark late duplicates and late modulo collisions, then regenerate budgets from measurements. Exact additional gas remains unmeasured here. |
| 5 | minor | test_progress.cairo:141 (`packages/quest/tests/test_progress.cairo:141`) | The progress oracle is only partially independent. | `plain_add` calls production `batch_count_of`, just as `progress_add` does. A lookup regression can affect both sides identically. Separate lookup tests reduce, but do not remove, this blind spot. | Implement a simple independent lookup in the test oracle. |

## Coverage

Reviewed commit **`4692361184148abff000d1ad42cb7d11c767a38a`**, all quest source and test files, `GAS.md`, and the accepted specification, including §3.5’s component assumptions.

**Conformance and edge cases.** All specified library types, functions, derives and error constants are present. Source inspection found the intended behavior for schedule boundaries through `u64::MAX`, saturation, completion once, interval-bound acceptance, prerequisites based on prior completion, pre-merge batch bounds, task-zero rejection, and page removal using the last ID. Tests meaningfully cover these pure behaviors and their specified panics.

Retirement checks correctly remain the component’s responsibility: `record_is_accepted` can return true for a retired quest’s unchanged record, while completed progress remains claimable.

**Packing.** For values within the documented field bounds, offsets and arithmetic round-trips match §3.3. Empty definitions decode as undefined. All six packers remain below `2^251`, even at full declared-type maxima. I independently checked all offset constants and the 128-entry power table. Packing oracles use independent arithmetic, but omit malformed inputs and out-of-range count fields.

**Caller assumptions.** `batch_count_of`, `batch_first_position`, and `prerequisites_met` rely on caller-supplied bounds. This is safe under §3.5: batches first pass through `batch_merge`, and prerequisite records come from at most seven validated conditions. Direct library callers must preserve those bounds. On an unmerged batch, `batch_count_of` returns only the **first** matching count; consequently, `progress_add` does not aggregate raw duplicates. That behavior is not explicit in the accepted function declaration.

**Cost and tests.** All **146 tests**, including **33 benchmark/baseline tests**, have budgets; none is marked ignored. Every recorded budget exactly equals `ceil(1.05 × recorded measurement)`, and source budgets match `GAS.md`. Benchmarks use a non-inlined input helper against constant folding; compiled execution could not be inspected. The sole production `u256` use splits a felt into limbs without wide arithmetic; its code-level justification is reasonable.

**Verification limits.**

- Formatting check: **passed**.
- Build, package tests, and live gas check: **blocked**, reporting `failed to open lockfile — Read-only file system`.
- PR #6 checks: **unverified**, because GitHub API access failed.
- Counterexamples and comparison counts were checked with foreground, in-memory integer calculations, not executed Cairo tests.
- Component storage, authorization, hooks, and deployment behavior are outside ARC-03a.

No files were changed, and no command remains running.