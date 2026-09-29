# [GPT-6-Astra] Audit — ARC-07a — cost and access control

## Verdict

**FAIL — AC-3’s exact-cost evidence is incomplete for `QuestDefinition`.**

No access-control, state-machine or storage-layout regression was found. Recorded worst-call costs remain within the permitted noise.

Audited checkout **`469ff60`** against published **`quiver_quest-v0.1.0` (`cd7c897`)**, ARC-06 and the ARC-03 audits.

## Findings

| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | major | mock_store.cairo:602 (`packages/quest/tests/mock_store.cairo:602`), GAS.md:538 (`packages/quest/GAS.md:538`) | **The definition benchmark does not isolate tracking overhead, so it cannot establish AC-3’s “exactly.”** | The hand-written silent path calls old `definition_new`; the store path calls new `DefinitionTrait::new`. Recorded costs are **1,502,350 versus 1,497,390**. Different validation/conversion work can conceal tracking overhead. The tracked comparison likewise differs by −4,560; tracked-minus-silent costs **155,500 versus 155,100**. The mechanism and reporter comparisons establish equality for their fixtures, but not this model. This is a measurement gap, not a demonstrated runtime regression. | Add matched definition benchmarks using identical construction, conversion, calldata and storage state: production `TrackNone` versus the same write with event code absent; `TrackAll` versus an unconditional equivalent event. Retain the old-validator comparison separately as migration evidence. |
| 2 | minor | GAS.md:637 (`packages/quest/GAS.md:637`) | **The claim that every budget equals `ceil(1.05 × measured)` is incorrect.** | **48 of 501** budgets are below that formula. For example, `bench_held_slot_last` measures **30,700**, with budget **31,458**, whereas the formula gives **32,235**. All budgets nevertheless satisfy the checker’s permitted range. | Describe retained tighter budgets accurately and reconcile the wording with CAIRO §2. Do not raise otherwise adequate caps merely to match the prose. |
| 3 | note | Verification | **Fresh Cairo execution and PR CI remain unverified.** | Build/tests and fresh gas measurement require filesystem writes, prohibited for this audit. The GitHub API request for PR #20 failed to connect. | Confirm fresh test/gas results and green CI in the implementation environment. |

## Coverage

**Optional tracking.** I inspected both mechanisms, their hand-written twins, dispatcher boundaries and baseline subtraction. Inputs become runtime contract calldata; the measured storage work is not folded into test constants. The fixtures use the same slots and argument shapes.

| Fixture | Constant | Emitter | Hand-written |
|---|---:|---:|---:|
| One-slot model, silent | 454,530 | 454,530 | 454,530 |
| One-slot model, emitting | 499,550 | 499,550 | 499,550 |
| Reporter, silent | 454,630 | — | 454,630 |
| Reporter, emitting | 498,230 | — | 498,230 |

These recorded figures support exact equality for those fixtures. Definition figures were independently reconciled against the raw table; finding 1 limits their interpretation.

**Worst-call costs.** Recomputed from each version’s recorded benchmark minus its matching baseline. Benchmark function bodies and fixtures are preserved apart from type renames and budgets.

| Call | Published 0.1.0 | 0.2.0 | Change |
|---|---:|---:|---:|
| `progress_many`, H=4, created | 6,213,063 | 6,205,843 | −7,220 |
| H=4, existing | 2,997,063 | 2,989,843 | −7,220 |
| H=4, created, writing hook | 8,027,983 | 8,020,763 | −7,220 |
| H=4, existing, writing hook | 4,811,983 | 4,804,763 | −7,220 |
| H=8, created | 11,430,213 | 11,416,073 | −14,140 |
| H=8, existing | 4,998,213 | 4,984,073 | −14,140 |
| H=8, created, writing hook | 15,060,053 | 15,045,913 | −14,140 |
| H=8, existing, writing hook | 8,628,053 | 8,613,913 | −14,140 |
| Worst `accept` | 1,921,540 | 1,917,170 | −4,370 |
| Worst `abandon` | 574,060 | 564,150 | −9,910 |
| Worst `define` | 2,590,440 | 2,583,680 | −6,760 |
| Worst `retire` | 1,003,240 | 1,003,540 | +300 |
| `claim` | 364,020 | 364,520 | +500 |

Retire increases **0.030%** and claim **0.137%**. The worst progress fixtures retain the late modulo-collision merge path. `define` is unchanged against ARC-06, but cheaper against the published release.

All **501** source budgets match GAS.md and satisfy:

`measured ≤ budget ≤ ceil(1.05 × measured)`

All **423** published baseline tests remain present. Exactly three existing caps increased:

- `prerequisites_met_when_each_completed_once`: **38,934 → 45,864**
- `quest_prerequisites_all_required_logic`: **28,371 → 32,256**
- `bench_prerequisites_met_seven`: **31,185 → 36,540**

Each has a `// gas: raised` explanation. They construct/walk larger record models; the component reads prerequisite records individually. The 53 unambiguous measured/budget pairs checked in BUDGETS.md also match GAS.md.

**Access control and state machine.** The eight `IQuest` mutators retain their checks: admin for define/retire/reporter changes, registered reporter for both progress methods, and player authorization for accept/abandon/claim. The internal layer remains trusted and unembedded.

Source tracing preserves completion and claim guards, writes before hooks, retired-by-hook skipping, whole-entry membership after hooks, renewal exclusion, pruning, acceptance rollover and kept-slot behavior. Access, claim, dependent-boundary and re-entry regression bodies are unchanged apart from imports/types/budgets. The previously accepted residual identity collision after a complete **2³⁰** acceptance cycle remains; this rewrite neither fixes nor worsens it.

**Storage and events.** All six packed layouts—A, B, C, P, R and H—retain their packing/unpacking logic, bounds and reserved-bit checks after renames and equivalent helper calls. Storage member names and key tuples remain unchanged. Status updates preserve the definition fields in slot A. Event selectors, keys and data remain unchanged under `TrackAll`; action events remain outside optional model tracking.

**Checks completed:** formatting, Markdown links, diff whitespace, recorded-gas consistency and source comparisons passed. No files were written, and no command remains running.