# PENDING — `quiver_achievement`: the accepted design breaks the 20M cap in storage mode

| | |
|---|---|
| Asked by | `[Opus 5.5]` orchestrator of `quiver`, 2026-09-29 |
| Decides | The project manager (D-128); it amends the API accepted at A-G1 (D-131) for `quiver_achievement` |
| Rule | [The cost cap](2026-09-28-A-G1-amendment-cost-cap.md): the worst call the package allows stays under 20M L2 gas, refused at definition time otherwise; "the same rule applies to `quiver_achievement` (ARC-04)" |
| Blocks | The brief of ARC-04. No agent is launched before the answer |

## Why

The API accepted at A-G1 (ARC-01 §3.10, §3.11) is the design `quiver_quest` had before D-135:
achievements are listed on their tasks' pages (28 live per task), and `progress_many` in storage
mode walks the pages of each of its 16 tasks and writes one progress record per achievement reached.
Its worst call (ARC-01 §5.2) writes **448 records**. What `quiver_quest` measured prices that call:
a record created in the transaction costs about **0.46M** L2 gas (0.45M on Sepolia), an overwritten
one about 0.06M (0.03M), an event about 0.05M. **448 created records alone are about 200M**, ten
times the cap. Even one achievement per task (16 records) is about 7.5M of writes plus reads and
events; a title of three tiers on each of 16 tasks is about 25M. The quest's remedy (a held list)
does not transfer: an achievement is never accepted.

What Grim World uses: **event mode only** (D-131: titles on `quiver_achievement` in event mode; the
game keeps its own "distinct" counters and reports their progress as tasks). Event mode reads and
writes nothing; its worst call is 16 events, about 1.3M (ARC-03b measured the quest's).

## Options

| | Option | Worst call (estimates from `quiver_quest`'s measured prices) | For the game | Work |
|---|---|---|---|---|
| **a** | **0.1.0 in event mode only; storage mode designed later.** `define` (stored, with points in the event), `retire`, `progress` and `progress_many` in `Mode::Event`, the views of the definitions, reporter access control. No per-player storage, no completion, no claim in 0.1.0. A-6 ("storage or event per call") is *adapted* for this package until a consumer needs storage | About 1.3M (16 events); `define` a few created slots | Everything it needs (titles in event mode); ARC-04 short | A small lot on ARC-03's frame |
| b | **Per-task counters in storage mode.** Progress keeps one packed slot per (player, task) (the count, saturating), not one per achievement; tiers sharing a task (A-7) are thresholds on that count, evaluated when read (views, claim) and, for the completion event, from the definitions on the task, whose number per task is capped at definition time. Claim sets a bit in a per-player bitmap | 16 created counter slots (about 7.4M) + definition reads and completion events for the achievements on each task: about 13M at 4 achievements per task, about 18M at 7 (to be measured; cap set on the measure) | Fits; storage mode available for a future title that a rule reads | A design and a lot of the size of ARC-03c, with its audits |
| c | Keep A-G1's design and cut the bounds (fewer entries per call in storage mode, one achievement per task) | Under 20M only at about 1 achievement per task and 16 entries, or 4 entries at 4 per task | Tiers sharing a task (A-7) would not fit storage mode | Constants only |

## Recommendation

**(a) for 0.1.0, with (b) as the design of a later minor version**, when a consumer needs a title
that a rule reads (none today: ADR-0004, "titles that a rule reads: none"). It gives the game what it
needs now, is the cheapest to build and to audit, and keeps the worst call far below the cap. (b) is
the right storage design, since tiers share a task, but it is a lot of the size of ARC-03c, and no
consumer needs it yet. (c) breaks A-7 in storage mode and is not recommended.

If (a): ARC-04 is briefed on it (Opus 5.5, `[GPT-6-Astra]` audit), with its worst calls measured,
and ARC-01 §3.10, §3.11 and §5.2 are amended "by D-…" in the same pull request.
