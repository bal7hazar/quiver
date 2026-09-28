# ARC-01 — Analysis of `quest` and `achievement`, and the API of their native rewrites

## Agent
Title: `[Opus 5.5] ARC-01 analysis quest and achievement` · Model: Opus 5.5 (`claude-opus-5-5`) ·
Profile: `research`

## Goal
After this task, `docs/research/ARC-01-quest-achievement.md` exists: an analysis, from the
source, of the Dojo packages `quest` and `achievement` of `cartridge-gg/arcade`, and a proposed
**API of their native rewrites** `quiver_quest` and `quiver_achievement` (pure Cairo library
plus Starknet component, no Dojo), precise enough for the owner to accept it at gate A-G1 and
for an implementer to start ARC-02 and ARC-03 from it without inventing anything.

## Context
- Read [README.md](../../README.md), [PLAN.md](../../PLAN.md), [docs/CAIRO.md](../CAIRO.md) in
  full (it binds the API you propose: cost first, packing, events for what is only shown).
- Reference source, in your worktree, read-only: `ref/arcade/`, a clone of
  `cartridge-gg/arcade` at commit **`c53fadc`** (2026-07-22), the commit ADR-0004 was written
  from. Read `packages/quest/` and `packages/achievement/` in full (sources, tests, README,
  `packages/quest/docs/`); read elsewhere in `ref/arcade/` only what they import.
- Documents of the game, in your worktree, read-only: `ref/grimworld/`, an export of
  `bal7hazar/grimworld` at commit **`e8a6a72`**:
  - `docs/architecture/ADR-0004-arcade-packages.md`: modes, the mapping to the game, **points
    3 to 5** (event mode untested; quest edge cases);
  - `docs/architecture/ADR-0007-native-starknet.md` § Access control, § Events are an interface,
    § Arcade packages;
  - `docs/needs/arcade.md`: the needs **A-1 to A-9**;
  - `docs/design/06-guild.md` § Quests, `docs/design/13-titles.md`,
    `docs/design/14-quests-region-1.md` (what the game will build on the packages);
  - `docs/briefs/ORCH-quiver.md` §1 and §4 (the shape of a package, what this report must hold);
  - `PLAN.md` § Track ARC.
- Decisions that bind you: D-124, D-125 (rewrite without Dojo, one repository, one package
  per feature, CI by affected package); D-126 (names: `quiver_quest`, `quiver_achievement`).
- Depends on: ARC-00 (merged).

## Scope
- In: reading the two packages and what they use; the report below; checking on scarbs.xyz
  (web, read-only) whether the names `quiver_quest` and `quiver_achievement` are free, and how
  a workspace publishes packages one by one (Scarb 2.19 documentation).
- Out: any Cairo code, any workspace or CI file (ARC-02); building or running anything;
  `leaderboard`, `social` and the other Arcade packages (read one only to explain an import);
  changes to the game's documents (a disagreement with them is an escalation).
- Allowlist: `docs/research/ARC-01-quest-achievement.md` and `REPORT.md` at the worktree root.
  Nothing else. Your profile cannot commit: the orchestrator commits your report and opens
  the pull request.

## What the report holds

Write it in English, for two readers: the owner deciding at A-G1, and the implementer of
ARC-03. Tables where they fit. Every claim about the Dojo packages carries its location
(`packages/quest/src/component.cairo:123`). Statements about behaviour are from reading: say
so; nothing was run.

1. **The two Dojo packages as they are.** Data model (every model: keys, fields, types,
   packing), storage and event modes (what `to_store` changes, call by call), hooks (when they
   fire, with what), intervals (how a period is computed, what "aligned" means there),
   prerequisites (how conditions and unlocks are counted), completion and claim, events.
   **Every dependency on Dojo** (world, models, store, events, permissions, test helpers) and
   what replaces it natively.
2. **The defects of ADR-0004 points 3 to 5** that concern these two packages (event mode
   untested; unlock firing on every decrement; an inactive dependent quest reverting the whole
   progress call; a recurring prerequisite underflowing the lock counter of a one-off quest),
   each **confirmed or refuted in the source** with the lines and the scenario, plus any other
   defect you find. Each becomes a **test case** for ARC-03 or ARC-04: name, given, when, then.
3. **The API of the native packages**, for `quiver_quest` in full and `quiver_achievement` in
   full:
   - the library: types and pure functions (state in, state out), with Cairo signatures;
   - the component: storage layout (with packing, field widths and their reason), events
     (kept small: an event costs gas on every call, and events are an API frozen like one),
     entrypoints (external and internal), and the **hook traits** the consumer implements,
     with signatures;
   - what the consumer must implement or call, shown as a short sketch of a consumer contract;
   - **access control**: who may define quests and achievements, who may report progress
     (only contracts the consumer registers; A-5: the game's ephemeral contract, through its
     results interface), who may claim and for whom; what the component enforces and what it
     leaves to the consumer;
   - the modes: storage or events, **chosen per call** (A-6), and exactly what each mode can
     and cannot do;
   - what is deliberately not kept from the Dojo packages, and why.
4. **Against the game's needs A-1 to A-9**: one row each, covered, adapted or missing, and how.
   Also say which of these the package serves and which stay with the game: the 3 active
   quests of design/06 (is there an accept step?), diminishing merit on repeat (does the claim
   hook get a completion count?), the daily board draw of design/14, "distinct" counters of
   design/13 (T-2), tiers kept once reached (T-3).
5. **Cost**: storage writes (and reads) per progress call and per claim, worst case stated (a
   task shared by N quests or achievements, a quest with prerequisites, a daily interval);
   events emitted; what packing saves against one slot per field. Estimates from the layout,
   labelled as estimates; the measurements come with ARC-03.
6. **The workspace**: layout of the repository (folders, root `Scarb.toml`, one package per
   feature), how a package depends on another inside the workspace and once published, **CI by
   affected package** (a change runs the package and its dependents only; the whole workspace on
   `main` and before a release; how dependents are found), publication per package on
   scarbs.xyz (versions, changelog, `GAS.md`, tags), and whether the names are free on the
   registry today.
7. **Open questions for gate A-G1**: each with the options and your recommendation.

## Interfaces
None created in code. The report proposes the interfaces of `quiver_quest` and
`quiver_achievement`; the owner accepts or amends them at A-G1.

## Acceptance criteria
- [ ] AC-1 Sections 1 to 7 above are present and complete, for both packages.
- [ ] AC-2 Every statement about the Dojo packages cites a file and line at `c53fadc`.
- [ ] AC-3 Each defect of ADR-0004 points 3 to 5 that concerns quest or achievement is marked
      confirmed or refuted, with its scenario and a named test case.
- [ ] AC-4 The API gives Cairo signatures for every library function, entrypoint, hook and
      event, and the storage layout with field widths.
- [ ] AC-5 Needs A-1 to A-9 each have a row: covered, adapted or missing.
- [ ] AC-6 Access control is specified: roles, who may report progress, what is enforced.
- [ ] AC-7 Cost per progress call and per claim is given for the worst case, labelled as an
      estimate.
- [ ] AC-8 The workspace, CI by affected package and per-package publication are described,
      with the registry availability of the two names.
- [ ] AC-9 Open questions for A-G1 are listed with options and a recommendation.

## Verification
- `wc -l docs/research/ARC-01-quest-achievement.md`, and every section heading present.
- Spot-check three citations yourself against `ref/arcade/` before you finish.

## Report
`REPORT.md` (COMMON.md §6): summary, files changed, the commands you ran (reading and web
lookups), cost "—" (no Cairo built), each acceptance criterion with where it is met,
deviations, escalations, open questions. Your turn ends when `REPORT.md` is written.
