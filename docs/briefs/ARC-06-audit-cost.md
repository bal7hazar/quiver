# ARC-06 audit — cost

## Agent
Title: `[GPT-6-Astra] Audit ARC-06 cost` · Model: `gpt-6-astra`, reasoning high · Profile: `audit`
(codex, read-only sandbox). Your final message is your report.

## What you audit
Pull request #19, checked out in your working directory: the cost of the model-and-store pattern
(D-143) and of the quest definition rewritten on it. The specification:
`docs/briefs/ARC-06-model-store.md`; the claims: `docs/research/ARC-06-model-store.md` (the cost
section) and `packages/quest/GAS.md` (section "The store and the definition model"); the rules:
`docs/CAIRO.md` §1 to §6.

## Lens: cost
1. The benchmarks that compare a hand-written write with `Store::set` (untracked, tracked; created
   and overwritten slots) and a hand-written read with `Store::get`: do they measure what they
   claim (baselines, constant folding, the same slots in both arms)? Is "the store costs exactly
   what the same code costs by hand, the event aside" supported?
2. The quest definition through the store: the claimed 4 560 saving on a write and 6 760 on the
   worst `define`; `has_definition` reading slot A alone; `get_definition` reading C only with
   conditions: correct and measured?
3. No worst call of `quiver_quest` raised (the 20M cap and the measured figures of 0.1.0); budgets
   within 5 %; no budget raised without a written reason.
4. Anything in the pattern that would raise a cost when ARC-07 applies it to every model (a model
   read whole where a field would do; an event emitted where 0.1.0 emitted none): name it.

## Report
In the audit form of the game's OPERATIONS §6 (`# [GPT-6-Astra] Audit — ARC-06 — cost`, Verdict,
Findings, Coverage).
