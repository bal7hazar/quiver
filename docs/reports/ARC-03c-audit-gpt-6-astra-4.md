# [GPT-6-Astra] Audit — ARC-03c — security and cost

## Verdict

**PASS WITH FINDINGS**

At **`6fc8832`**, no major remains **within this limited pass and the project manager’s approved practical-wrap exception**.

Finding **6 is resolved**. Finding **2 is resolved at the old 16-bit boundary and closed under the approved widening**, with the documented residual at `2^30`. The third pass’s minor corrections are implemented. Some surrounding documentation remains stale.

## Findings

Closed findings retain their original severity.

| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 6 | major | component.cairo:537 (`packages/quest/src/component.cairo:537`), regression:513 (`packages/quest/tests/test_component_reentry.cairo:513`) | **Resolved:** accepting another quest no longer discards an unchanged quest’s batch. | The window check is removed. Whole-entry membership preserves Q2 after Q1’s hook accepts Q3. The regression represents the old 16-bit history, checks Q3’s number is 65,538, and asserts Q2 receives 3 counts followed by 1, totaling 4. | None. |
| 2 | major | component.cairo:336 (`packages/quest/src/component.cairo:336`), renewal regression:464 (`packages/quest/tests/test_component_reentry.cairo:464`) | **Resolved within the approved practical bound.** | The earlier history now leaves counter 65,537. Renewed Q2 receives 65,538 rather than its old number 2, so neither positional equality nor fallback membership matches. A complete `2^30` identity cycle remains possible; see coverage below. | Retain the documented residual; do not describe identity uniqueness as unconditional. |
| 4 | minor | GAS.md, BUDGETS.md, ARC-01 §5.1 | **Resolved:** the specific third-pass wording is corrected. | Saturated claim states **2 writes, 2 overwritten, 1 changed slot**. The post-hook read description matches the restored implementation, and the revised completing-quest bound covers the recorded grid. | None for these corrections. |
| 7 | minor | CHANGELOG.md:93 (`packages/quest/CHANGELOG.md:93`), GAS.md:561 (`packages/quest/GAS.md:561`) | **Some documentation was not updated with the widening.** | CHANGELOG still places `kept` at bit **240**. General packing comments still say no field straddles bit 128. The historical kept-slot comparison mixes new snforge figures with old network estimates: regrowth should estimate **662,538**, shrink **434,364**, and acceptance growth **1,885,222**. | Update the stale layout comments, comparison estimates and derived savings; distinguish historical figures from current ones. |
| 5 | note | Verification | **Runtime measurements and CI remain independently unverified.** | The read-only restriction prevents rebuilding/running Cairo tests and fresh gas measurements. GitHub API access failed. | Confirm the reported test/resource results and CI in the implementation environment. |

## Coverage

This pass was limited to acceptance identity, its packing and interval-width consequences, targeted regressions, affected costs, and the named minor corrections. The governing exception was read from `origin/main`.

**Packing and the counter split.** The implemented layout is consistent:

| Bits | Field |
|---|---|
| `[0,32)` | First quest ID |
| `[32,80)` | First interval ID |
| `[80,110)` | First acceptance number |
| `[110,140)` | Counter |
| `[140,172)` | Second quest ID |
| `[172,220)` | Second interval ID |
| `[220,250)` | Second acceptance number |
| `250` | Kept marker |
| `251` | Reserved |

The decoder reconstructs the counter as:

`counter_low + counter_high × 2^18`

The low portion contains 18 bits; the high portion contains 12. Neither overlaps an entry.

Packing rejects either interval at `2^48` or above, either acceptance number at `2^30` or above, and an oversized counter. With every field maximal, the packed value is exactly **`2^251 − 1`**, below the Stark field modulus. Consequently, packing cannot silently wrap through field arithmetic.

Unpacking rejects bit 251 and correctly decodes bit 250 as `kept`. A kept-only slot remains an empty list slot because readers test quest IDs. The counter remains confined to slot 0, and wrapping it to zero does not clear the kept marker.

Independent integer checks passed **20,000 random round trips**, all **251 used single-bit positions**, counter-split boundaries, all five narrowed-field overflow cases, and reserved-bit boundaries. These were mathematical checks, not Cairo execution.

**Interval narrowing.** A valid schedule **can** produce an interval ID of `2^48`: `(start=0, end=0, duration=1, interval=1)` does so at timestamp `2^48`. Its rejection is the explicitly documented new acceptance limit, not a truncated calculation.

For an active recurring schedule:

`interval_id = floor((time − start) / interval)`

Since the interval is at least one second, reaching the limit requires at least `2^48` elapsed seconds—approximately 8.9 million years. A late absolute timestamp alone does not force rejection: a recently started schedule can still have a small interval ID. One-off quests retain ID zero.

The guard checks the full `u64` result **before writes**. At `2^48 − 1`, acceptance and progress remain valid. At `2^48`, acceptance refuses with the specified error; the earlier held interval expires normally and cannot alias interval zero. `quest_current_interval` deliberately still exposes the full schedule result, as the boundary regression asserts. No unintended truncation or rejection of a representable interval was found.

**Residual at `2^30`.** The widening does not mathematically eliminate the original renewal collision. An outstanding acceptance can survive a complete number cycle; renewing the same quest in the same interval can then recreate its entire tuple and receive the enclosing batch.

However:

- It now requires **1,073,741,824 intervening acceptance-number increments**.
- Accepting a *different* quest cannot recreate that tuple or cause the former false exclusion.
- Ordinary counter rollover, including acceptance number zero, is sound.
- GAS.md explicitly describes the remaining same-quest renewal case.

I accept this residual under the project manager’s explicit choice of a practical widening to at least 29 bits. The implementation provides 30 bits without adding slots. This is risk reduction under that decision, not an unlimited-lifetime uniqueness guarantee. The quoted aggregate gas expenditure should be treated as illustrative; a universal minimum of 0.7M per acceptance is not established by the fixtures.

**Remeasured costs.** Recorded benchmark subtraction and network repricing reconcile:

| Held / hooks | Created P/R: snforge / network estimate | Existing P/R: snforge / network estimate |
|---|---:|---:|
| 4 / empty | 6,213,063 / 6,168,215 | 2,997,063 / 2,796,215 |
| 4 / one new hook slot | 8,027,983 / 7,960,711 | 4,811,983 / 4,588,711 |
| 8 / empty | 11,430,213 / 11,340,517 | 4,998,213 / 4,596,517 |
| 8 / one new hook slot | 15,060,053 / 14,925,509 | 8,628,053 / 8,181,509 |

The largest specified fixture leaves **4,939,947 L2 gas** below 20M. Reads return to **23 at H=4** and **44 at H=8**. The affected acceptance and abandonment maxima reconcile at **1,921,540** and **574,060** respectively.

Static consistency checks found all **423 recorded test budgets** equal to `ceil(1.05 × recorded gas)`. Formatting, Markdown links and diff-whitespace checks passed.

No files were written. All commands finished in the foreground; nothing remains running.