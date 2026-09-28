# [GPT-6-Astra] Audit — ARC-03b — security and cost

## Verdict

**FAIL**

A completion hook can retire a quest that the enclosing progress call subsequently completes. Critical re-entry and counter-boundary behavior also lacks tests. No unauthorized access through the supplied `IQuest` wrappers was identified.

## Findings

| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | major | component.cairo:269 (`packages/quest/src/component.cairo:269`), component.cairo:454 (`packages/quest/src/component.cairo:454`) | **A quest retired during a hook can still receive progress and complete.** | Define permanent Q1 and Q2 on the same task, each with target 1 and no acceptance requirement. Progress snapshots both IDs. Q1 completes; its hook calls internal `retire(Q2)`. The outer loop subsequently processes Q2 from its snapshot. It reads Q2’s definition but never checks `retired`, so Q2 completes and becomes claimable. This violates §3.5: “No path counts a retired quest.” The scenario requires a consumer hook performing retirement; it is not an admin-authorization bypass. | After reading A, skip retired quests before processing their schedule or player state. Add a hook-retirement regression checking progress, completion events, hooks and claimability. Escalate the specification’s assumption that page removal alone prevents subsequent progress. |
| 2 | major | mocks.cairo:117 (`packages/quest/tests/mocks.cairo:117`), test_component_claim.cairo:89 (`packages/quest/tests/test_component_claim.cairo:89`) | **Hook re-entry is untested.** | Hooks only read state, log calls or panic. The “after state written” tests never invoke `progress`, `claim` or `accept` from a hook. They therefore do not exercise the audit’s required re-entry scenarios or interactions with later quests in a batch. | Add configurable re-entering hooks. Exercise same-interval progress, duplicate claim, acceptance after completion, and operations on another quest. Assert counters, flags, events and reward-hook counts. |
| 3 | major | component.cairo:170 (`packages/quest/src/component.cairo:170`), test_component_define.cairo:149 (`packages/quest/tests/test_component_define.cairo:149`) | **The live-dependent ceiling has no behavioral test.** | Tests check small dependent counts and maximum-value packing, but none calls `define` when a prerequisite has `live_dependents == 0xffff`. `TOO_MANY_DEPENDENTS` appears in tests only as an error-string assertion. Removing the ceiling guard would escape these tests. Source inspection finds the guard correct today. | Seed a boundary fixture: test increment from 65,534 to 65,535, rejection of the next dependent with the specified error, rollback of earlier writes in that failed definition, and capacity recovery after retirement. |
| 4 | minor | test_component_bench.cairo:107 (`packages/quest/tests/test_component_bench.cairo:107`), test_component_bench.cairo:148 (`packages/quest/tests/test_component_bench.cairo:148`) | **Component “worst-case” batch benchmarks omit the more expensive merge path.** | Both use IDs `1..16`, taking the fast path. Sixteen distinct IDs `[1,…,15,129]` instead trigger a late modulo-128 collision and the full fallback. Existing library measurements, after subtracting their baselines, are 700,613 versus 118,996 gas. The event-mode component still emits sixteen events, but its declared worst-case input omits this additional work. | Benchmark late-collision inputs through both component modes, retaining the 448-quest storage witness. Regenerate the affected measurements and distinguish the §5.1 storage-operation maximum from a measured gas maximum. |

## Coverage

Reviewed checkout **`6421c1ca73bba903e0fe93c3e41f1ae1b9d39102`**: component, interfaces, component tests and mocks, README, CHANGELOG, GAS.md and BUDGETS.md, against the implementation brief, accepted API, A-10/A-11 and Cairo rules. Reviewed the component’s use of the library and prior ARC-03a audit reports; the audited library implementation is unchanged.

**Access control and ownership.** All eight mutating ABI entrypoints have appropriate checks and unauthorized-caller tests. Reporter status grants progress authority, not admin or player authority; each progress invocation reads the registry, so revocation applies to subsequent calls. The internal implementation is not embedded as an ABI, and the selector-absence test checks every `IQuest` entrypoint.

`MockQuest` uses distinct admin, reporter and owner identities. `MockBench` authorizes everyone only for measurements. `MockConsumer` deliberately leaves its own accept/claim wrappers unchecked to demonstrate the trusted internal layer; that test is not evidence of secure consumer ownership checks.

**State and algorithms.** Outside finding 1, source inspection supports interval-specific completion and claim protection, prerequisite enforcement, acceptance expiry, abandonment preserving counts, immutable definitions, retirement page compaction, and dependent-counter accounting. Unique validated conditions, immutable definitions and single retirement prevent counter underflow; the explicit ceiling prevents overflow.

Completion and claim state is written before their hooks, with no subsequent stale write to those records. Existing panic tests check rollback. Actual hook re-entry remains untested.

The declared deviations are reasonable:

- Writing progress only when it changes preserves behavior and avoids redundant writes.
- Returning `None` for an undefined quest’s current interval avoids treating empty storage as a valid permanent quest.

Internal event-mode progress performs no storage access and invokes no completion hook. The external wrapper necessarily adds one reporter-registry read; documentation should make this distinction explicit.

**Events and named cases.** All six event structures match §3.4, including keys and data. Tests inspect raw event serialization and verify that acceptance and abandonment emit nothing. All 69 named quest cases in §2 are represented: 68 by exact name, with `quest_packing_round_trip` covered by the existing type-specific round-trip tests. This establishes presence, not complete behavioral coverage; findings 2–3 identify additional gaps.

**Cost.** All **292 tests**—166 existing library tests and 126 component tests—have budgets, none is ignored, and every budget exactly equals `ceil(1.05 × recorded gas)`. Source budgets match GAS.md. Component and library tables in BUDGETS.md match the recorded figures; component baseline subtraction also matches.

The §5.1 witnesses are present, including 28 shared quests, seven uncached prerequisites, 16 entries, and retirement’s 22 reads/14 writes. Normal batch traversal writes each affected progress/record at most once. The two-task tests include comparison baselines, but do not automatically assert storage-syscall counts.

For the transaction-limit comparison, I use **1.1 billion L2 gas**, the published mainnet ceiling in Starknet’s [chain-information table](https://docs.starknet.io/learn/cheatsheets/chain-info). The recorded **704,333,046** gas is approximately **64.0%**, leaving **395,666,954** before consumer logic, real hooks, account execution and other overhead. The benchmark includes an acknowledged extra view call. Its roughly 1.996-billion-gas *test total* includes setup and should not be compared directly with a single production transaction.

This does **not** establish that the accepted 16-entry bound must universally be lowered. The package should document an integration budget covering task fan-out and hook costs; a consumer must enforce a smaller practical bound when its complete transaction exceeds that budget. Sixteen entries alone is not an execution guarantee.

**Verification limits.** Formatting, tracked Markdown links and diff-whitespace checks passed. Cairo build/tests and fresh gas measurements were not run because they require filesystem writes. GitHub API access failed, so PR #7’s CI status remains unverified. The retirement counterexample was checked by source tracing and an in-memory execution-order model, not executed Cairo.

No files were changed. No command remains running.