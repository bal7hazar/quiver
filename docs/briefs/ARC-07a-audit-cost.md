# ARC-07a audit — cost and access control

## Agent
Title: `[GPT-6-Astra] Audit ARC-07a cost and access control` · Model: `gpt-6-astra`, reasoning high ·
Profile: `audit` (codex, read-only sandbox). Your final message is your report.

## What you audit
Pull request #20, checked out in your working directory: `quiver_quest` 0.2.0 (see
`docs/briefs/ARC-07a-quest-0.2.0.md`, read with `git show origin/main:<path>`). The published 0.1.0
and its audits (`docs/reports/ARC-03*`) are the baseline: this rewrite must keep behaviour and cost.

## Lenses
1. **The criterion of AC-3, checked by you, not taken from the report**: a write of a model the
   consumer leaves untracked costs **exactly** a write with no event code; a tracked write costs the
   write plus the event. Read the benchmarks and their baselines (`GAS.md`, the tests that measure
   the constant and the emitter mechanisms): same slots, same shape, no folded constants; do the
   recorded figures support "exactly"?
2. **No worst call raised**: compare the 0.2.0 figures with 0.1.0's (`progress_many` at 4 and 8 held,
   `accept`, `abandon`, `define`, `retire`, claim); budgets within 5 %; the three raised budgets and
   their notes.
3. **Access control and state machine kept**: through `IQuest`, admin, reporter and player checks as
   in 0.1.0; the held list, acceptance numbers, completion once, claim once, the retired-by-hook skip,
   re-entry; nothing lost in the move from `logic/` to models.
4. **Storage layouts kept**: every packed layout of 0.1.0 unchanged, or the change named and measured.

## Report
In the audit form of the game's OPERATIONS §6 (`# [GPT-6-Astra] Audit — ARC-07a — cost and access
control`, Verdict, Findings, Coverage).
