# ARC-03a audit — `quiver_quest::logic`

## Agent
Title: `[GPT-6-Astra] Audit ARC-03a correctness and cost` · Model: `gpt-6-astra`, reasoning
high · Profile: `audit` (codex, read-only sandbox). You cannot write files: your final message
is your report.

## What you audit
Pull request #6, checked out in your working directory: `packages/quest/src/**`,
`packages/quest/tests/**`, `packages/quest/GAS.md`, the deliverable of
`docs/briefs/ARC-03a-quest-logic.md`. Read the brief first: it is the specification, with
`docs/research/ARC-01-quest-achievement.md` §3.1 to §3.3 (the accepted API: types, functions,
panics, packed layouts) and `docs/CAIRO.md`. You receive the deliverable and the
specification, not the author's reasoning. This library has no storage and no access control;
the component (ARC-03b) will rely on it, and on its packed layouts, for the security of the
package.

## Lenses
Design conformance, determinism and cost (the game's OPERATIONS §6). Check, with evidence:

1. **Conformance.** Every type and function of §3.2 exists with its signature and panics;
   the semantics that differ from Dojo (§3.2's table) hold: saturation at the total, no
   overflow anywhere, `u64` interval ids and counters, acceptance tied to its interval,
   prerequisites met on "completed at least once", the batch bound of 16 counted before
   merging, task id 0 rejected, pages kept contiguous on removal. Name any function whose
   behaviour a caller could not predict from the report.
2. **Packing.** For every packed type: the bit ranges are those of §3.3; no field can overflow
   into its neighbour for any value its type allows; the presence bits read an empty slot as
   `defined == false`; every packed felt is below 2^251; unpack(pack(x)) == x for all x, and a
   felt that is not the image of a valid value cannot unpack into a value that breaks an
   invariant the component would rely on. Check the tests' oracles are independent of the
   code they check.
3. **Edge cases a component would hit.** Counters at their maxima, a schedule at the edge of
   `u64` time, an interval id near 2^64, a batch of 16 duplicates, a full page, a record of
   a retired quest. Does any pure function panic where the report says it must not, or
   return silently where it must panic?
4. **Cost.** `docs/CAIRO.md` §3 and §6: arithmetic before loops, no `u256` without a written
   reason (one use is declared: judge it), every loop bounded; the benchmarks are on the
   worst cases the brief names and measure the function, not a folded constant; the budgets
   within 5% of the measures. Three helpers loop over the list they are given and rely on the
   caller for the bound: say whether that is safe for the component as §3.5 specifies it.
5. **Tests.** Are the named test cases the brief lists present and meaningful (would they fail
   if the rule they name were broken)?

## Report
Your final message, in this form (the game's OPERATIONS §6):

```markdown
# [GPT-6-Astra] Audit — ARC-03a — correctness and cost

## Verdict
PASS | PASS WITH FINDINGS | FAIL

## Findings
| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |

## Coverage
What was reviewed, what was not, and why.
```

Severities: `blocker`, `major` (wrong in a reachable case; a packing that can corrupt a
neighbour; a test that cannot fail), `minor`, `note`. Every finding needs evidence: a file and
line, a scenario, or a quoted rule.
