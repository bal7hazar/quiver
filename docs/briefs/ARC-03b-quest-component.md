# ARC-03b — `quiver_quest`: the Starknet component

## Agent
Title: `[Opus 5.5] ARC-03b quest component` · Model: Opus 5.5 (`claude-opus-5-5`) · Profile:
`implement`

Second lot of ARC-03. ARC-03a wrote `quiver_quest::logic` (types, packing, pure functions);
this lot wraps it in a Starknet component. After it, `quiver_quest` 0.1.0 is complete and the
orchestrator asks for its publication (D-132).

## Goal
After this task, `quiver_quest` has its **component**: storage, events, the trusted internal
layer, the optional external ABI with its access control, the hook trait the consumer
implements, and the views, exactly as the accepted API specifies; a mock consumer contract in
the tests; every named test case of the component; a gas budget on every test and a benchmark
on every worst case; the package's README and changelog ready for 0.1.0.

## Context
- **The specification**: [docs/research/ARC-01-quest-achievement.md](../research/ARC-01-quest-achievement.md),
  accepted at gate A-G1 ([decision](../decisions/2026-09-28-A-G1-api.md), D-131):
  §3.1; §3.3 storage (member names, keys); §3.4 events; §3.5 in full (hooks, internal
  functions, the step-by-step algorithms of `progress_many`, `accept`, `abandon`, `claim`,
  `retire`, `define`, the views, the error strings, the external ABI `IQuest` and `IQuestView`);
  §3.6 access control; §3.7 modes; §3.8 the consumer sketch; §5.1 the costs and worst cases;
  §2 the named test cases; §4 the needs, with the game's answers at A-G1 (A-10: at most 16
  distinct tasks per call; A-11: an acceptance expires at rollover with its progress).
- **The library**: `packages/quest/src/logic/`, `src/errors.cairo` (ARC-03a, merged). Use its
  functions; **do not change their behaviour**. A defect found in the library is fixed in
  this lot only if it blocks the component, with a test, and named in the report.
- **[docs/CAIRO.md](../CAIRO.md), in full**: one write per record per transaction, read only
  what the call needs, a gas budget on every test, benchmarks on the worst case.
- [docs/WORKSPACE.md](../WORKSPACE.md): the gas tool, the CI.
- Depends on: ARC-03a merged.

## Scope

**In** (all in `packages/quest/` unless said):

1. `src/component.cairo` (`#[starknet::component] pub mod QuestComponent`): the storage of
   §3.3 with the prefixed member names; the events of §3.4 (`QuestDefined`,
   `QuestProgressed`, `QuestCompleted`, `QuestClaimed`, `QuestRetired`, `QuestReporterSet`,
   and any other §3.4 lists) with their keys; the trait `QuestHooksTrait` of §3.5; the
   internal impl (`define`, `set_reporter`, `progress`, `progress_many`, `accept`,
   `abandon`, `claim`, `retire`, `assert_reporter`, the reads); the external impls `QuestImpl`
   (`IQuest`, access-checked as §3.6 says) and `QuestViewImpl` (`IQuestView`), each optional
   to embed. `src/interface.cairo` for the two interfaces.
2. The algorithms **exactly as §3.5 writes them step by step**: read what the step needs and no
   more; skip, never revert, for a quest-level reason; state written before any hook; one write
   per record per call; `Mode::Event` reads and writes nothing and emits one
   `QuestProgressed` per merged non-zero entry.
3. **Access control** (§3.6): `define`, `retire` and `set_reporter` through `authorize_admin`;
   `progress` and `progress_many` only from a registered reporter; `accept`, `abandon` and
   `claim` through `authorize_player`; the internal layer checks nothing and says so in its
   doc comments and the README.
4. **Tests** (`tests/`), written before the code, each with its gas budget, against mock
   consumers in the tests (a contract embedding the external impls, and one embedding only the
   internal layer as §3.8 does):
   - **every named test case of §2 not written in ARC-03a**: D-1 event mode (all four),
     D-2 to D-8, D-13 (the access-control cases, including that the internal layer is not
     reachable from the ABI unless the consumer exposes it), the "Also tested" list, the
     acceptance, batch, retirement and live-dependents cases added in the report's fix loops;
     their names as the report gives them;
   - the hooks: called once per completion and per claim, after the state is written, with
     `completions` and `claim_index`; a hook that panics reverts the call;
   - events: exact contents and keys, checked with `spy_events`;
   - the daily rollover with `start_cheat_block_timestamp` (A-11: an unfinished acceptance is
     lost at rollover with its progress).
5. **Benchmarks**, one per entrypoint on the worst case of §5.1 (a task shared by 28 live
   quests; 7 prerequisites first observed during progress; 16 entries; retire with 7
   dependents' counters), each a test with its budget; the estimates of §5.1 set beside the
   measures in the report.
6. `GAS.md` regenerated; **`docs/BUDGETS.md`** created (per entrypoint: measured value,
   budget, date, commit; docs/CAIRO.md §2); `README.md` (usage with a consumer sketch, bounds,
   access control and the trusted internal layer, modes, the daily alignment on 00:00 UTC
   when `start` is a multiple of 86 400, the one-call-per-player-per-transaction rule);
   `CHANGELOG.md`: a `0.1.0` section (not yet released) listing the API.

**Out**: changes to the API of the report (a gap or a contradiction is an **escalation**);
`quiver_achievement` (ARC-04); the workspace, CI and gas tooling; the version number;
publishing: no sub-agent publishes, ever (D-132, `docs/briefs/COMMON.md` §2); the orchestrator
asks for `quiver_quest` 0.1.0 after this lot.

**Allowlist**: `packages/quest/src/**` (the library only for a blocking defect, named in the
report), `packages/quest/tests/**`, `packages/quest/GAS.md`, `packages/quest/README.md`,
`packages/quest/CHANGELOG.md`, `docs/BUDGETS.md`. Anything else is an escalation.

## Interfaces
Those of ARC-01 §3.3 to §3.5: `quiver_quest::component::QuestComponent`,
`quiver_quest::interface::{IQuest, IQuestView}` and their dispatchers, `QuestHooksTrait`. If a
signature cannot be written as given in Cairo 2.19, write the closest form and say why.

## Acceptance criteria
- [ ] AC-1 Storage, events, hooks, internal functions, external ABI and views exist as §3.3 to
      §3.5 specify (deviations named and justified).
- [ ] AC-2 Every named test case of §2 for `quest` exists (in ARC-03a or here) and passes; the
      report lists them with their file.
- [ ] AC-3 Access control: every entrypoint of `IQuest` refuses an unauthorised caller, with a
      test each; the internal layer is documented as trusted.
- [ ] AC-4 One write per record per call, shown by a test that counts writes or by gas on a
      two-task batch; `Mode::Event` writes nothing.
- [ ] AC-5 Every test has a budget; `scripts/gas.py packages/quest --check` passes; benchmarks
      on every worst case of §5.1; `docs/BUDGETS.md` written.
- [ ] AC-6 README and CHANGELOG ready for 0.1.0; the pull request's CI is green.

## Verification
`scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml build`,
`cd packages/quest && snforge test`, `scripts/gas.py packages/quest --check`,
`scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml fmt --check`,
`python3 .github/ci/check-links.py`; then `gh pr checks <n> --watch --interval 30` until green.

## Report
`REPORT.md` (COMMON.md §6): the gas table of every test and benchmark with the §5.1 estimate
beside each worst case, the named test cases and their files, deviations, escalations. Branch
`feat/ARC-03b-quest-component`; pull request `[Opus 5.5] ARC-03b quest component`.
Foreground only; your turn ends when `REPORT.md` is written.
