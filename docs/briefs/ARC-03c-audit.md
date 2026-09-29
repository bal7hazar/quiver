# ARC-03c audit — `quiver_quest`: the component on the held list

## Agent
Title: `[GPT-6-Astra] Audit ARC-03c security and cost` · Model: `gpt-6-astra`, reasoning high
· Profile: `audit` (codex, read-only sandbox). You cannot write files: your final message is
your report.

## What you audit
Pull request #10, checked out in your working directory: all of `packages/quest/` (library,
component, interfaces, tests, mocks, `README.md`, `CHANGELOG.md`, `GAS.md`), `docs/BUDGETS.md`
and the amended parts of `docs/research/ARC-01-quest-achievement.md` (§3.1, §3.2, §3.3, §3.5,
§5.1, marked "Amended by D-135"). The specification: `docs/briefs/ARC-03c-quest-held.md` (read
it from `origin/main` with `git show origin/main:docs/briefs/ARC-03c-quest-held.md` if it is not
in your checkout), `docs/decisions/2026-09-28-quest-cost-cap.md` (D-135), the cost cap
`docs/decisions/2026-09-28-A-G1-amendment-cost-cap.md`, `docs/CAIRO.md`. Earlier audits of this
package are in `docs/reports/` (ARC-03a, ARC-03b): check that their findings stay fixed. This is
the whole of `quiver_quest` 0.1.0, which the game will call from its persistent contract to
record quests and pay their rewards; its publication is asked after this audit.

## Lenses
Security, access control and ownership first; then design conformance and cost. Check, with
evidence:

1. **Access control.** Through `IQuest`, can a caller who is not the admin define, retire or set a
   reporter; can a caller who is not a registered reporter report progress; can a caller not
   authorised for a `player_id` accept, abandon or claim for it? Is the internal layer
   unreachable from the ABI unless the consumer exposes it?
2. **The held list.** Can a player hold more than `MAX_HELD`; hold a quest twice; progress a quest
   they do not hold, whose acceptance expired (A-11), that is completed in this interval, retired
   or locked; make another player's quests progress? Is the lazy pruning at accept correct in
   every case (expired, completed, retired, a full list with stale entries)? Can a stale entry
   ever be counted as held (by progress, by `quest_is_accepted`, by `quest_held`)? Is the packing
   of the list sound (field widths, reserved bits, an empty slot), and does it work for any
   `MAX_HELD` up to 8 as the brief requires?
3. **State machine and re-entry.** Completion once per interval, claim once, prerequisites checked
   at accept, `live_dependents` and the retirement guard kept, the retired-by-hook skip kept;
   hooks called after the state is written; a hook that accepts, abandons, retires or progresses
   during a progress call.
4. **Deviations beyond the brief**, to judge: the player record lost `active` and
   `accepted_interval` (acceptance now lives only in the held list); a new view
   `quest_held(player_id)`.
5. **Cost.** The worst calls measured for `MAX_HELD` 4 and 8, with empty hooks and with a hook
   writing one slot, all under 20M L2 gas: are they truly the worst the package allows (the
   merge path, every held quest completing, the most expensive prerequisite state)? Does
   `GAS.md` state the changed-slot cost and the changed slots per entrypoint, and are the figures
   corrected for snforge counting a whole test as one transaction consistent? Budgets within 5 %.
6. **Tests.** Every named case of ARC-01 §2 for `quest` present and able to fail; the ones whose
   meaning changed (the report lists 13) still test a real rule; the new cases of the brief.

## Report
Your final message, in the audit form of the game's OPERATIONS §6 (`# [GPT-6-Astra] Audit —
ARC-03c — security and cost`, Verdict, Findings table with severity, location, finding,
evidence, fix, Coverage). Severities: `blocker` (a caller gains what the rules forbid; state
corrupted), `major` (wrong in a reachable case; a rule without a test that could fail), `minor`,
`note`. Every finding needs evidence.
