# A-G1 amendment — the worst call must be affordable: under 20M L2 gas (2026-09-28)

| | |
|---|---|
| Decided by | The project manager `[Fable 5.1]`, 2026-09-28 22:35 UTC, by cross-session message (D-128: the project manager decides, reports to the owner) |
| Amends | [A-G1](2026-09-28-A-G1-api.md) (D-131): the bounds of `quiver_quest` 0.1.0 (Q-2, Q-14, Q-19 and the prerequisites of §3.1) |
| Trigger | ARC-03b measured the worst `progress_many` the accepted bounds allow at **about 704M L2 gas** for the component alone: 16 tasks, each shared by 28 live quests, each with 7 prerequisites first observed |

## Decision

A bound that a consumer can reach by configuration and that no transaction can pay is a way to
make a game revert. **Bounded execution means bounded by what a transaction affords**, not only
by a number of iterations. For scale: the game's worst tick is 5.1M L2 gas as a whole
transaction, and its expedition target is about 1.8M per action.

Before ARC-03 is accepted:

1. Measure the cost of `progress_many` as a function of its three factors: tasks per call,
   live quests per task, prerequisites first observed. Publish the table in
   `packages/quest/GAS.md`.
2. Set the caps of 0.1.0 so that **the worst call the package allows stays under 20M L2 gas**,
   and **refuse at definition time** what would exceed them. Quests per task is the factor to
   cut first: the game needs a few quests per task, not 28.
3. State the network's per-transaction limit compared with, and its source.
4. The game's own use is a benchmarked case: at most 16 tasks per call, 3 active quests and one
   contract.

The publication request of `quiver_quest` 0.1.0 is checked against these points. The same rule
applies to `quiver_achievement` (ARC-04).

## Carried out by

ARC-03b, fix loop 2 (the orchestrator's brief to the resumed agent), then the `[GPT-6-Astra]`
re-audit.
