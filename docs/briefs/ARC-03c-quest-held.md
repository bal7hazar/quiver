# ARC-03c — `quiver_quest`: progress walks the player's held quests (D-135)

## Agent
Title: `[Opus 5.5] ARC-03c quest held list` · Model: Opus 5.5 (`claude-opus-5-5`) · Profile:
`implement`

Third lot of ARC-03. ARC-03a wrote the library (merged); ARC-03b wrote the component (pull
request #7, not merged) and measured that its progress path cannot fit the project manager's cap:
the worst call its bounds allowed cost about 683M L2 gas, and even one quest per task measures
20.6M at 16 tasks. The project manager decided **D-135**: the package bounds what a player
holds, not what a task reaches. This lot rewrites the progress path on that rule and keeps the
rest of ARC-03b. After it, `quiver_quest` 0.1.0 is complete.

## Goal
After this task, every quest needs acceptance, a player holds at most `MAX_HELD = 4` quests (a
constant of 0.1.0, at most 8), `progress` and `progress_many` walk the player's held quests
instead of the tasks' pages, prerequisites are checked at acceptance, and **the worst call the
package allows is measured under 20M L2 gas**, with the measurements that prove it.

## Context
- **The decision**: [docs/decisions/2026-09-28-quest-cost-cap.md](../decisions/2026-09-28-quest-cost-cap.md)
  (D-135) with its evidence; [the cost cap](../decisions/2026-09-28-A-G1-amendment-cost-cap.md)
  (the worst call under 20M L2 gas; refusals at definition or acceptance time, not at progress).
- **Your starting point**: your worktree is on a branch cut from ARC-03b's branch
  (`feat/ARC-03b-quest-component` at `2703bb6`): its component, tests, mocks, benchmarks, the cost
  grid and probes. Read its `REPORT.md`, archived as `docs/reports/ARC-03b-report.md`, and
  `packages/quest/GAS.md` (the cost model: about 1.17M per completed quest, of which about 0.92M
  are its two changed slots; a slot changed by a transaction costs about 402 000 L2 gas once per
  slot per transaction).
- **The API**: [docs/research/ARC-01-quest-achievement.md](../research/ARC-01-quest-achievement.md)
  §3 (accepted at A-G1, D-131), amended by D-135 as below; §2 the named test cases.
- The game: A-10 (at most 16 distinct tasks per call), A-11 (an acceptance expires at rollover
  with its progress), A-12 (every quest is accepted before it progresses; at most 4 held: 3 active
  quests and one contract; the cost of a progress call depends on the held quests only).
- [docs/CAIRO.md](../CAIRO.md) in full; [docs/WORKSPACE.md](../WORKSPACE.md).

## Scope

**In:**

1. **The held list.** A per-player record of the quests the player holds, at most `MAX_HELD`
   (constant, 4; the code must work for any value up to 8), packed in as few slots as possible
   (state the layout and its bit ranges). Design it so that **a progress call changes as few slots
   as possible**: count them for each case (nothing completes; one completes; all complete) and
   choose the layout that minimises the changed slots of the common case, then of the worst.
   Expired acceptances (A-11) and completed or retired quests are pruned lazily, at the next
   `accept`, unless pruning at progress is cheaper overall: measure, say which, and why.
2. **Acceptance mandatory**: `needs_accept` disappears from the definition (and its bit from the
   layout); `accept` checks the schedule, retirement, the prerequisites (and caches `unlocked`),
   that the current interval is not completed, and that the list has room (a new error string,
   for example `'Quest: too many held'`); `abandon` removes the quest from the list.
3. **Progress walks the list**: read the held list, and for each held quest whose acceptance is
   current and which is live, apply the batch to its tasks; everything else of ARC-03b's
   algorithm (saturation, one write per record, completion, hook after the state is written,
   the retired-by-hook skip, `Mode::Event` reads and writes nothing) is kept. Prerequisites are
   not read at progress.
4. **Task pages**: progress no longer needs them. Remove the pages, their caps
   (`QUESTS_PER_PAGE`, `MAX_PAGES`, `'Quest: task full'`) and the page helpers of the library, and
   simplify `define` and `retire` accordingly, **unless** an entrypoint still needs them; say
   which you did and why. Keep `live_dependents` and the retirement guard of Q-20.
5. **Measurements**, each a budgeted benchmark with its baseline:
   - the worst call the package allows, **measured for `MAX_HELD = 4` and for 8** (build the 8
     case in the tests, for example a test-only instantiation or a seeded list; say how), with
     16 entries, every held quest completing, its tasks the worst for the merge; **with hooks
     empty, and with an `on_quest_complete` hook that writes one storage slot**;
   - **the game's use**: 16 entries, 3 quests and one daily contract held and completing, with 0
     to 2 prerequisites, many quests defined on the same tasks but not held;
   - `accept` and `abandon` at their worst (7 prerequisites, a full list with expired entries).
   All must be under 20M L2 gas; if one is not, stop and report the figures.
6. **`GAS.md`** (the section below the generated table) and **`docs/BUDGETS.md`**: the measured
   cost of a changed slot (from ARC-03b's probes, re-measured if the code changed), and **for
   each entrypoint the number of slots it changes** (best, common and worst case); the worst call
   of point 5 against the 20M cap and against the network's limit (1.1 × 10⁹ L2 gas, "Max L2 gas
   per transaction", docs.starknet.io, Learn > Cheatsheets > Chain info, read 2026-09-28).
7. **Tests**: every named test case of ARC-01 §2 for `quest` still exists and passes, adapted to
   mandatory acceptance (name the ones whose meaning changed and why); new cases: the list full,
   an expired acceptance pruned, a completed quest leaving the list, a quest held by one player
   not progressed by another's call, re-entry from a hook that accepts or abandons.
8. **The documents, first**: amend ARC-01 §3.2, §3.3, §3.5 and §5.1 for `quest` (types, layouts,
   algorithms, costs) with a note "Amended by D-135", in the same pull request; `README.md`
   (usage, bounds, the integration budget with the measured worst calls); `CHANGELOG.md` 0.1.0.

**Out**: `quiver_achievement`; the workspace, CI, gas tool; any `scarb publish`: no sub-agent
publishes, ever (D-132); the orchestrator asks for `quiver_quest` 0.1.0 after this lot.

**Allowlist**: `packages/quest/**`, `docs/BUDGETS.md`, and the `quest` parts of
`docs/research/ARC-01-quest-achievement.md` (§3.1 bounds, §3.2, §3.3, §3.5, §5.1). Anything else
is an escalation.

## Acceptance criteria
- [ ] AC-1 Acceptance mandatory; at most `MAX_HELD` held; progress walks the held list and reads
      no task page and no prerequisite.
- [ ] AC-2 The worst call measured under 20M L2 gas for `MAX_HELD` = 4 and 8, with empty hooks and
      with a hook writing one slot; the game's use measured.
- [ ] AC-3 `GAS.md` and `docs/BUDGETS.md` give the changed-slot cost and the changed slots per
      entrypoint.
- [ ] AC-4 Every named test case passes (adapted where the rule changed, listed); the new cases of
      Scope 7 exist; every test has a budget; `scripts/gas.py packages/quest --check` passes.
- [ ] AC-5 ARC-01 §3 and §5.1 amended in the same pull request; README and CHANGELOG ready for
      0.1.0.
- [ ] AC-6 The pull request's CI is green.

## Verification
`scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml build`,
`cd packages/quest && snforge test`, `scripts/gas.py packages/quest --check`,
`scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml fmt --check`,
`python3 .github/ci/check-links.py`; then `gh pr checks <n> --watch --interval 30` until green.

## Report
`REPORT.md` (COMMON.md §6): the held-list layout and its changed-slot counts, the measurements of
Scope 5 against 20M, the tests whose meaning changed, deviations, escalations. Branch
`feat/ARC-03c-quest-held`; pull request `[Opus 5.5] ARC-03c quest held list`, which supersedes #7
(the orchestrator closes #7). Foreground only; your turn ends when `REPORT.md` is written.
