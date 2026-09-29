# ARC-07a — `quiver_quest` 0.2.0 on the pattern of CAIRO.md §7

## Agent
Title: `[Opus 5.5] ARC-07a quest 0.2.0` · Model: Opus 5.5 (`claude-opus-5-5`) · Profile: `implement`

ARC-07 rewrites both packages on the pattern settled by ARC-06 and reviewed by the owner (D-147). It
is split in two lots: **ARC-07a** (this brief), `quiver_quest` 0.2.0, shown to the owner as ARC-06
was; then **ARC-07b**, `quiver_achievement` 0.2.0, briefed after the owner's review of this lot.

## Goal
After this lot, `quiver_quest` is organised as the owner asks: **no `logic/` folder**; every stored
entity a model in `models/` in the arcade layout, value types in `types/`, what belongs to no entity
in `helpers/`, all scoped in traits with short names; one store; **each tracked model's event
optional for the consumer**, chosen at compile time, at no cost on a write. Behaviour, events, error
strings, storage layouts, tests and gas caps of 0.1.0 are kept, except where the pattern needs a
change, measured and named. The package's version becomes **0.2.0** (its module paths change).

## Context
- **The rule**: [docs/CAIRO.md](../CAIRO.md) §7 and §8; the owner's rule D-143; **the owner's review
  of ARC-06, D-147** (`cd /home/claude/projects/grimworld && git fetch -q origin && git show origin/pm/client-visual-track:docs/decisions/2026-09-29-arc-06-owner-review.md`
  until it is merged on the game's `main`): (1) `logic/` disappears; (2) a model's event is
  optional for the consumer.
- **The pattern and its reference**: [docs/research/ARC-06-model-store.md](../research/ARC-06-model-store.md)
  (the mechanism; §5 the questions for ARC-07; §6 the classification of every model of both packages;
  the cost audit's notes: keep reads selective and read slot A once; keep model writes apart from
  action events); the reference model `packages/quest/src/models/definition.cairo`, `models/index.cairo`,
  `events/`, `store.cairo`; the audits of ARC-06 in `docs/reports/ARC-06-audit-*`.
- **What exists**: `packages/quest/` (0.1.0 published, plus ARC-06's definition model on `main`).
- The arcade reference, read-only in `ref/arcade/` of your worktree (`cartridge-gg/arcade` at
  `c53fadc`, `packages/quest/src/`).

## The mechanism of optional tracking (the owner's second remark)

A model's `Tracked<M>` impl (ARC-06) says **which** event the model has. Whether a write **emits** it
is the **consumer's** choice, made at compile time:

- The package declares a tracking trait the consumer implements, e.g.
  `pub trait QuestTracking<TContractState> { const DEFINITION: bool; const REPORTER: bool; … }` (one
  constant per tracked model), and ships two ready impls: `TrackAll` (every tracked model emits, as
  0.1.0) and `TrackNone`. The component's impls take it as a generic impl parameter, like the hooks;
  `Store::set_x` of a tracked model emits `if Tracking::X`.
- **Alternative, if the constant's branch is not free**: one impl parameter per tracked model of an
  emitter trait (`Emit` calls `emit`, `Silent` is an empty inlined body), chosen by the consumer.
- **Cost, the criterion**: a write of an untracked choice must cost **exactly** a write with no event
  code at all (measured to the unit against ARC-06's hand-written baseline); a tracked choice costs
  the write plus the event, as in ARC-06. **Measure both mechanisms first**, adopt the one that meets
  the criterion (the constant, if the compiler folds it), and write the figures in
  `docs/research/ARC-06-model-store.md` (a section "Optional tracking, ARC-07a") and `GAS.md`. If
  neither meets it, stop and report the figures.
- The consumer's sketch in the README shows both choices; Grim World's choice is its own.

## Scope

**In** (all in `packages/quest/`):

1. **`src/logic/` removed.** Its contents go to: `models/` (one file per stored entity, arcade's
   shape: struct in `models/index.cairo`, `...Impl of ...Trait`, `...Assert`, `mod errors`, its
   storage conversion, its `Tracked` impl when it has an event), `types/` (schedule, task, mode,
   batch entry and the other value types), `helpers/` (bits and packing primitives, the batch merge
   if no type owns it), each scoped in traits; `events/` one file per event. No free function without
   a written reason.
2. **Every model** listed in ARC-06 §6 for `quiver_quest`: the definition (kept), the quest's status
   sharing slot A with the definition (read once per path, as ARC-06 said), progress, record, held
   list, reporters. Each read and written only through the store; tracked or not as §6 classifies
   (untracked models emit nothing; action events such as `QuestCompleted` stay emitted by the
   component where 0.1.0 emits them, never duplicated by a model's event).
3. **Optional tracking** as above, with tests: under `TrackAll` each tracked `set_x` emits exactly
   once per write; under `TrackNone` nothing; an untracked model never.
4. **Names**: `QuestDefinition` is the model only; 0.1.0's slot types get slot-specific names;
   short, scoped, the design's words.
5. **Kept**: behaviour, events and their fields, error strings, storage layouts (unless the pattern
   needs a change: measure and name it), every test (moved and renamed where the paths change), every
   gas budget (no raise without a `// gas: raised, <reason>` note); the worst calls of 0.1.0 not
   raised beyond noise, remeasured and stated.
6. **Documents**: README (the layout, the consumer's sketch with the tracking choice, the
   integration budget), `CHANGELOG.md` section `[0.2.0]` (not yet released: the breaking changes of
   paths and names, the tracking choice), `GAS.md`, **`docs/BUDGETS.md`'s `quiver_quest` tables
   refreshed** (left stale since ARC-06), and ARC-01 §3 amended where the paths and names change.
7. `Scarb.toml` version `0.2.0`.

**Out**: `quiver_achievement` (ARC-07b); publication (never by an agent: D-132).

**Allowlist**: `packages/quest/**`, `docs/BUDGETS.md`, `docs/research/ARC-06-model-store.md`, the
`quest` parts of `docs/research/ARC-01-quest-achievement.md`. Anything else is an escalation.

## Acceptance criteria
- [ ] AC-1 No `logic/` folder; the layers of §7; no free function without a written reason.
- [ ] AC-2 Every stored entity is a model read and written only through the store.
- [ ] AC-3 Optional tracking chosen by the consumer at compile time; an untracked write costs exactly
      a write with no event code (measured); tests for `TrackAll` and `TrackNone`.
- [ ] AC-4 Behaviour, events, errors and layouts of 0.1.0 kept (or each change named and measured);
      every test kept; worst calls not raised beyond noise.
- [ ] AC-5 README, CHANGELOG `[0.2.0]`, GAS.md, BUDGETS refreshed, ARC-01 amended; version 0.2.0.
- [ ] AC-6 The pull request's CI is green.

## Verification
`scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml build`, `cd packages/quest && snforge test`,
`scripts/gas.py packages/quest --check`, `scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml fmt --check`,
`python3 .github/ci/check-links.py`; then `gh pr checks <n> --watch --interval 30` until green.

## Report
`REPORT.md` (COMMON.md §6): the layout, the tracking mechanism and its measured cost, **the paths the
owner should read** (the tracking trait, two or three models, the store), the gas table against 0.1.0,
deviations, escalations. Branch `feat/ARC-07a-quest-0.2.0`; pull request
`[Opus 5.5] ARC-07a quest 0.2.0`. Foreground only; your turn ends when `REPORT.md` is written.
