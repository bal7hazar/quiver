# PENDING — ARC-03c after three fix loops: one new major on acceptance numbers

| | |
|---|---|
| Asked by | `[Opus 5.5]` orchestrator of `quiver`, 2026-09-29 02:45 UTC |
| Decides | The project manager (the game's OPERATIONS §6: after three fix loops on one lot, the orchestrator escalates; the project manager chooses a last loop limited to named findings, a merge with the findings carried as open points, or a restructured task) |
| Lot | ARC-03c, `quiver_quest` on the held list (D-135), pull request [#10](https://github.com/bal7hazar/quiver/pull/10) at `10f46d9`, CI green, 417 tests within budget |
| Audits | `[GPT-6-Astra]`, four passes: [1](../reports/ARC-03c-audit-gpt-6-astra-1.md), [2](../reports/ARC-03c-audit-gpt-6-astra-2.md), [3](../reports/ARC-03c-audit-gpt-6-astra-3.md) (the fourth pass; the second pass is archived as 2) |

## Where the lot stands

Resolved over the three loops: the cost model (a new slot versus an overwritten one, measured and
priced at the network's figures), the worst calls under 20M L2 gas (6.29M at `MAX_HELD` = 4; 15.31M
at the layout's limit of 8 with a hook writing one slot; the game's use 4.63M), held-list slots kept
instead of zeroed, a quest renewed by a hook excluded from the running call, the one-write rule
bounded by gas guards with the exact write counts recorded. No access-control, packing, claim or
retirement defect found in four passes.

**Open, major (finding 6 of the fourth pass, introduced by fix loop 3):** each held entry carries a
16-bit acceptance number; the player's counter wraps over its lifetime. To exclude a quest renewed by
a hook, the running call now treats an entry whose number was issued during the call as renewed.
When the counter has wrapped, a hook that accepts **another** quest can issue the number that an
unchanged held quest already carries: that quest is then skipped, and the counts of that batch are
lost, not delayed. The audit reproduced it in a model: Q2 held with target 10, a batch reporting 3
skipped, a later batch reporting 1, Q2 ends at 1 instead of 4.

What it takes to reach it: one player who has made 65 536 acceptances in the package's lifetime (at
least 0.7M L2 gas each, so about 4.6 × 10¹⁰ L2 gas of their own), and a consumer whose completion
hook accepts a quest. **Grim World's hooks do neither** (its `on_quest_complete` frees an active
slot; acceptance is the player's act in a hub). The loss falls on that player's own progress only.

**Open, minor:** saturated `claim` still says "1 overwritten" where it overwrites 2 (only P changes);
the ARC-01 §5.1 summary of a completing quest's post-hook reads is stale.

## Why a number of 16 bits cannot be fixed by windows

Fix loop 1 compared whole entries: a renewal after a lifetime wrap looked identical. Fix loop 3
excluded numbers issued during the call: an unchanged entry sharing such a number looked renewed. A
16-bit number alone cannot tell the two apart. The cause is the width, not the rule.

## Options

| | Option | Effect |
|---|---|---|
| **a** | **A last fix loop limited to findings 6 and 4**, with the direction: make a wrap impossible in practice and identify an acceptance by its whole entry. For example, narrow the interval id to 48 bits (2⁴⁸ one-second intervals are about 8.9 million years) and widen the acceptance number and the counter to at least 29 bits, so that a wrap needs about 5 × 10⁸ acceptances by one player (about 3.8 × 10¹⁴ L2 gas); then drop the window check and compare whole entries. The agent measures the cost and stops if the layout does not fit | Removes the defect by construction; one more audit pass (`[GPT-6-Astra]`); the worst calls may move slightly |
| b | Merge #10 with finding 6 carried as an open point, documented in the README (a consumer whose hook accepts quests must not rely on progress after 65 536 acceptances by one player), fixed in 0.1.1 | Publication of 0.1.0 with a known defect that the game cannot reach |
| c | Restructure: a new lot redesigns how acceptances are identified | Slowest |

## Recommendation

**(a).** The defect is narrow and unreachable for the game, but it loses progress rather than
delaying it, and 0.1.0 is the version other consumers will read. The fix is a layout change of a
few fields with a clear rule, of the size of one loop. The minor finding and the stale summary go
with it. If the agent finds the layout does not fit, it stops with the figures, and (b) remains.
