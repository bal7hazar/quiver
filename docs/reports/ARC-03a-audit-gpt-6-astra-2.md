# [GPT-6-Astra] Audit — ARC-03a — correctness and cost

## Verdict

**PASS WITH FINDINGS**

Findings **1–5 are resolved** at `5f297ed`. No new correctness defect was found in the fixes. The remaining finding is a verification limitation: Cairo execution, fresh gas measurements, and PR checks could not be verified in this environment.

## Findings

Severities for rows 1–5 are their original classifications; all are closed.

| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | major | types.cairo:138 (`packages/quest/src/logic/types.cairo:138`) | **Resolved:** definition counts cannot spill into neighboring fields. | Packing checks `task_count <= 3` and `condition_count <= 7` before arithmetic. Regression tests reject 4/255 tasks and 8/16 conditions with the specified panic. | None. |
| 2 | major | types.cairo:257 (`packages/quest/src/logic/types.cairo:257`) | **Resolved:** page length is constrained during packing and unpacking. | Packing rejects lengths above seven. Unpacking checks the entire quotient above bit 223, rejecting both length 8 and higher reserved bits before conversion. | None. |
| 3 | minor | types.cairo:281 (`packages/quest/src/logic/types.cairo:281`) | **Resolved:** reserved progress bits no longer become `claimed`. | The `u128` conversion rejects bits ≥128; `claimed <= 1` rejects bits 98–127. Tests reject bits 98 and 128 and independently distinguish bits 96 and 97. | None. |
| 4 | minor | test_bench.cairo:160 (`packages/quest/tests/test_bench.cairo:160`) | **Resolved:** benchmarks include both previously missing expensive batch paths. | `[1,…,15,15]` and `[1,…,15,129]` reach the final fast-path entry before falling back. Recorded measurements are 749,113 and 753,023 gas; the larger case has budget 790,675. | None; independently rerun measurements when available. |
| 5 | minor | test_progress.cairo:133 (`packages/quest/tests/test_progress.cairo:133`) | **Resolved:** the progress oracle has an independent lookup. | `plain_lookup` scans by index and preserves the first match, including a zero count, without calling production lookup code. Both public functions now document their merged-batch expectation. | None. |
| 6 | note | Verification commands | Runtime verification remains incomplete. | Build, `snforge test`, and gas check fail with `failed to open lockfile: Read-only file system`. `gh pr checks 6` cannot connect to GitHub. | Confirm tests, fresh gas measurements, and CI in a writable, connected environment. |

## Coverage

Reviewed the complete changes from `4692361` to **`5f297edc155c421857edfc71421cae2dce75f739`**, against the audit brief, implementation brief, accepted API, and Cairo rules.

**Reserved-bit checks.** Each decoder now accepts exactly its layout’s numeric range:

| Packed type | Accepted felt range | Enforcement |
|---|---|---|
| Definition | `[0, 2^216)` | Final quotient must fit `u16` |
| Tasks | `[0, 2^192)` | Final total must fit `u32` |
| Conditions | `[0, 2^224)` | Remaining quotient must equal zero |
| Page | `[0, 2^227)` | Length quotient must be ≤7 |
| Progress | `[0, 2^98)` | `u128` conversion and final quotient ≤1 |
| Record | `[0, 2^194)` | Accepted interval must fit `u64` |

Definition bits **198 (`defined`)**, **199 (`retired`)**, and **200–215 (`live_dependents`)** remain independent. Zero still decodes as undefined; `live_dependents = 65535` remains valid; bit 216 and higher are rejected.

All valid encodings preserve the original layouts and remain below `2^251`. Out-of-range public count values now panic rather than round-trip; round-trip guarantees apply to the documented packed domains. These guards enforce encoding validity, while semantic validation remains with constructors and the component.

I checked the guard mathematics using boundary values, every single-bit position, deterministic random felts, and all 256 possible narrow-field values. These were **in-memory integer checks, not Cairo execution**. The new panic tests have specific expected errors and meaningful inputs.

**Cost.** The changes add no loops, wide arithmetic, or extra limb splits. Definition, tasks, and record reuse existing narrowing conversions. Conditions, page, and progress check already-computed quotients.

Recorded pack-and-unpack benchmark costs are:

| Type | Previous gas | Current gas | Change |
|---|---:|---:|---:|
| Definition | 42,710 | 43,450 | +740 |
| Tasks | 31,590 | 31,390 | −200 |
| Conditions | 35,520 | 35,520 | 0 |
| Page | 36,690 | 37,630 | +940 |
| Progress | 28,660 | 29,130 | +470 |
| Record | 29,220 | 29,020 | −200 |

These are combined benchmark totals from `GAS.md`, **not isolated unpack costs or independently reproduced measurements**. Packing benchmarks retain opaque inputs and full round-trip assertions; new batch benchmarks also use opaque inputs and a matching setup baseline.

All **166 tests**, including **36 benchmark/baseline tests**, have budgets, none is ignored, and every budget exactly equals `ceil(1.05 × recorded gas)`. Source budgets and `GAS.md` agree.

Unchanged schedule, record, definition, and page algorithms retain the prior audit conclusions. Caller-bounded lookup and prerequisite loops remain safe under §3.5’s validated-input workflow. The sole production `u256` use remains the justified felt-to-limbs conversion.

Formatting and diff-whitespace checks **passed**. Component behavior remains outside this audit. No files were changed, and no command remains running.