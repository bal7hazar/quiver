# [GPT-6-Astra] Audit — ARC-03c — security and cost

## Verdict

**FAIL**

The cost model incorrectly treats an allocation charge as a charge for every changed slot. A hook can also abandon and reaccept a quest that the enclosing call subsequently progresses, contrary to the published guarantee. Exact write-count coverage remains incomplete.

No authorization bypass through `IQuest`, duplicate claim, or packing corruption was found.

## Findings

| # | Severity | Location | Finding | Evidence | Fix |
|---|---|---|---|---|---|
| 1 | **major** | GAS.md:391 (`packages/quest/GAS.md:391`), BUDGETS.md:23 (`docs/BUDGETS.md:23`) | **The 402,000 L2 charge is misidentified, invalidating the blanket transaction corrections and pruning comparison.** | Starknet’s constants assign 402,000 to `allocation_cost`; allocation counts initial-zero → final-nonzero cells. Updating an existing nonzero cell does not incur that allocation charge. The probes compare initial allocation with subsequent writes inside the same test; they do not establish the stated cost for existing cells in another transaction. Claim’s P/R and the game’s cached records are already nonzero. See the cost evidence below. | Separate allocations, updates, clears and unchanged writes. Add probes covering those transitions and restoration to the initial value. Correct GAS, BUDGETS, README and amended §5.1; redo the pruning comparison. |
| 2 | **major** | component.cairo:527 (`packages/quest/src/component.cairo:527`), README.md:139 (`packages/quest/README.md:139`) | **Same-interval reacceptance defeats the advertised hook-acceptance exclusion.** | Hold Q1 and Q2 on task T, each target 1. Q1’s completion hook calls `abandon(P,Q2)`, then `accept(P,Q2)`. Acceptance prunes completed Q1 and recreates `(Q2,0)`. The outer snapshot contains the identical pair; `still_held` finds it and Q2 completes from the earlier batch. README says a quest accepted by a hook waits for the next call. Existing mocks allow only one action per configured hook and miss this composition. This requires a consumer hook, not an authorization bypass. | Distinguish acceptance instances and exclude renewed entries from the outer call; add the combined regression. Alternatively, explicitly resolve and document the weaker membership semantics before publication. |
| 3 | **major** | test_component_progress.cairo:158 (`packages/quest/tests/test_component_progress.cairo:158`) | **The named “one write” tests do not assert write counts.** | Assertions check resulting state, events and hooks. Baseline tests expose resource differences for manual inspection, but nothing asserts them. The completing test has 502,834 gas headroom; the noncompleting test has 300,025. A redundant write preserves every behavioral assertion, and the recorded rewrite cost is only about 57,099 before packing overhead. GAS equality detects measurement drift, but does not assert the one-write rule. | Add an automated resource-count assertion for the completing, noncompleting and duplicate-entry cases. Check one P write, plus one R write only on completion, excluding mock-hook writes. |
| 4 | **minor** | GAS.md:524 (`packages/quest/GAS.md:524`) | **Some changed-slot counts are inaccurate.** | With K > 0, `define` changes **3 + K** slots, not the table’s **2 + K**. Setting a reporter to its existing value changes zero slots. At saturated `claims`, claim changes P but leaves R unchanged, although it still writes R. | Distinguish storage writes from changed slots and correct best/common counts in both cost documents. |
| 5 | **note** | Verification | **Runtime and CI verification remain incomplete.** | Build/tests and fresh gas measurement require filesystem writes. GitHub API access failed. Formatting, Markdown links and diff-whitespace checks passed. | Reproduce build, all tests, gas checks and PR #10 checks in the writable implementation environment. |

## Coverage

Reviewed checkout **`617bbe67f2717fa1d2cd42e3c43c06e4da51460c`**, the complete quest package, specified documents, D-135, both briefs from `origin/main`, earlier audits, and the implementation report.

**Access control and state.** All eight mutating ABI functions retain their required checks. Reporter authority does not grant admin or player authority. The internal implementation is not automatically exposed through the ABI. Source inspection supports completion once per interval, claim once, prerequisite checking and caching at acceptance, dependent-counter accounting, and retirement protection. Completion and claim write state before invoking hooks.

The earlier ARC-03b retirement-from-hook defect remains fixed. Its dependent-ceiling and re-entry regression tests remain present. ARC-03a’s packing guards, expensive merge fixtures and independent progress oracle also remain fixed; page-specific findings became inapplicable when pages were removed.

**Held list and deviations.** Ordinary acceptance/pruning preserves uniqueness, capacity and order. Expired, completed, retired and inactive entries cannot progress or return true from `quest_is_accepted`.

`quest_held` **does return stale entries**, deliberately and explicitly documented. Its length is therefore not the number of live acceptances. I consider this raw view acceptable with that contract.

Removing `QuestRecord.active` and `accepted_interval` is a reasonable single-source-of-state design. Packing isolates both 96-bit entries, rejects reserved bits, and uses quest ID zero as the empty sentinel. Independent Python checks covered 10,000 packing round trips, every bit position, and 1,012 list-length/liveness combinations across capacities 1–8. These were mathematical checks, not Cairo execution. The eight-entry Cairo fixtures exercise progress through seeded storage; they do not run acceptance with `MAX_HELD` compiled as eight.

**Cost evidence.** The [0.14.2 constants](https://raw.githubusercontent.com/starkware-libs/sequencer/main/crates/blockifier/resources/blockifier_versioned_constants_0_14_2.json) specify the allocation charge. I independently found the same constants embedded in installed snforge 0.61. Allocation counting selects zero-to-nonzero transitions, and [fee calculation charges those allocations](https://raw.githubusercontent.com/starkware-libs/sequencer/main/crates/blockifier/src/fee/resources.rs). [snforge calculates state resources from the final state diff](https://raw.githubusercontent.com/foundry-rs/starknet-foundry/v0.61.0/crates/forge-runner/src/gas.rs).

Applying that distinction to the recorded benchmark deltas gives these **derived corrections, not fresh measurements**:

| Case | Published standalone L2 figure | Derived L2 figure |
|---|---:|---:|
| Claim | 1,168,020 | 364,020 |
| Abandon first of four | 1,308,460 | 504,460 |
| Game benchmark | 5,275,716 | 4,471,716 |
| Accept, four completed entries pruned | 2,091,300 | 1,689,300 |

The last case needs special handling: pruning clears the second list slot, cancelling its setup allocation in the benchmark difference.

The four principal progress fixtures remain credible allocation-heavy witnesses: late-collision merge, three late-position tasks per quest, every held quest completing, and distinct fresh hook slots.

| Held quests | Empty hooks | One fresh slot per completion hook |
|---|---:|---:|
| 4 | 6,131,373 | 7,946,293 |
| 8 | 11,279,423 | 14,909,263 |

Those recorded figures remain below 20M; the largest is about **74.5%** of the project cap and **1.36%** of the published [1.1-billion network limit](https://docs.starknet.io/learn/cheatsheets/chain-info). Finding 1 does not invalidate these fresh-slot witnesses. Exact worst-case acceptance still needs comparison against mixed stale/live lists with recurring schedules, not only all-expired and all-completed fixtures.

**Tests and budgets.** All **372 tests** have budgets; none is ignored. Every source budget matches GAS.md and equals `ceil(1.05 × recorded gas)`. All **69 named quest cases** are represented: 68 exact names and the type-specific packing family. The report’s 13 adaptations retain meaningful assertions, subject to the write-count gap above.

No files were changed. All commands finished in the foreground; nothing remains running.