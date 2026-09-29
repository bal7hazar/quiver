# ARC-06 — The pattern of CAIRO.md §7: model, storage, tracked event, store

## Agent
Title: `[Opus 5.5] ARC-06 model and store pattern` · Model: Opus 5.5 (`claude-opus-5-5`) · Profile:
`implement`

## Goal
The owner rejected the shape of quiver's code (D-143): the layering of `cartridge-gg/arcade` was not
kept. After this task, the pattern that every Cairo repository of the programme will follow exists,
**decided, measured and shown on one model**: how a stored entity is a model (a struct, its storage,
its event when the indexer tracks it), how the store reads and writes it and emits a tracked model's
event on every write, at no run-time cost beyond the write and the event themselves. The reference is
**one model of `quiver_quest`, the quest definition**, rewritten in the arcade layout. The project
manager shows that one model to the owner before anything else is reworked (ARC-07 rewrites both
packages as 0.2.0 afterwards).

## Context
- **The rule**: [docs/CAIRO.md](../CAIRO.md) **§7 and §8** in full (the layers, scoped functions,
  every stored entity a model, the store emits on write, the organisation lens), and the owner's
  decision (the game's `docs/decisions/2026-09-29-code-organisation.md`, D-143; read it with
  `cd /home/claude/projects/grimworld && git show origin/main:docs/decisions/2026-09-29-code-organisation.md`).
- **The reference layout, read before writing anything**: `ref/arcade/packages/quest/src/` in your
  worktree (`cartridge-gg/arcade` at `c53fadc`, read-only): `models/definition.cairo` (the struct's
  trait, `DefinitionTrait::new`, `definition.is_active(time)`, the `...Assert` impl, `mod errors`),
  `models/index.cairo`, `store.cairo` (`Store`, `get_x`, `set_x`), `events/` (`index.cairo` and one
  file per event), `types/`, `component.cairo`. Keep their shape and names; replace Dojo's world with
  Starknet storage.
- **What exists**: `packages/quest/` (`quiver_quest` 0.1.0, published; do not change its published
  behaviour): `src/logic/` (free functions: `definition_new`, `schedule_is_active`, …),
  `src/logic/types.cairo` (the packed layouts and `StorePacking` impls), `src/component.cairo`
  (storage members, `QuestDefined` and other events, the internal and external layers),
  `packages/quest/GAS.md` (the cost of a created slot, about 459 000 L2 gas in snforge, and of an
  overwritten one, about 57 000; an event about 48 500).
- Budget: the worst calls of `quiver_quest` are measured under 20M L2 gas (README, GAS.md); the
  pattern must not raise them beyond noise.

## Scope

**In:**

1. **The mechanism** (written in `docs/research/ARC-06-model-store.md`, and in code):
   - how a model declares that it is **tracked, at compile time** (a trait the model implements with
     its event type, an associated constant, or another form Cairo 2.19 supports); never a run-time
     lookup;
   - how the store is built on a component's storage (arcade's `Store` wraps a world: say what
     replaces it: a struct over `ComponentState`, a trait of the component, or other), and how
     `Store::set_x` writes the model and, **if and only if it is tracked**, emits its event, while an
     untracked model's `set` emits nothing and costs no more than a hand-written write;
   - how a model maps to its storage when it spans several slots (the quest definition today uses
     three: definition, tasks, conditions): one model with a `Store` implementation over several
     slots, several models, or other; measured;
   - whether the mechanism is a **shared package of quiver** (propose its name under D-126,
     `quiver_<x>`; packages depend on it by path in the workspace, by version once published) or a
     **convention** written in each package (and then how its correctness is checked), with the
     reason; if a package, it contains the mechanism only, with its own tests and `GAS.md`.
2. **Its cost**, benchmarks with baselines: a hand-written write of a packed slot against `Store::set`
   of an untracked model and of a tracked model (write plus event), for a created and an overwritten
   slot; a read by hand against `Store::get`; the difference must be the event and nothing else, or
   say what it is.
3. **The reference implementation on ONE model**: the quest definition of `quiver_quest`, in the
   arcade layout under `packages/quest/src/`: `models/definition.cairo` (the struct's
   `#[generate_trait]` impl with `new`, `is_active` and the behaviour the definition owns, its
   `DefinitionAssert` impl, its `mod errors`), `models/index.cairo`, its storage conversion
   (`StorePacking`, keeping **the storage layout of 0.1.0** unless the pattern needs another,
   measured), its event (`events/`, the definition event of 0.1.0 as the tracked event), and the
   store's `get_definition` and `set_definition`; the component's `define` and the reads of a
   definition go through the store. Tests of the model and the store, each with a gas budget; the
   package's existing tests still pass; its worst calls not raised beyond noise.
4. **Nothing else of the package is rewritten**: the rest of `src/logic/` and the component stay as
   they are (ARC-07 does the rest). Keep the published 0.1.0 behaviour; the version in `Scarb.toml`
   stays 0.1.0; the change goes under `Unreleased` in `CHANGELOG.md`.

**Out**: the other models of `quiver_quest`; `quiver_achievement`; the game; publishing (never, by an
agent: D-132).

**Allowlist**: `packages/quest/**`; a new package `packages/<name>/**` if you propose a shared package
(it joins the workspace by the existing `members = ["packages/*"]`); `Scarb.lock`;
`docs/research/ARC-06-model-store.md`; `docs/BUDGETS.md` (a line for the mechanism). Anything else is
an escalation.

## Acceptance criteria
- [ ] AC-1 `docs/research/ARC-06-model-store.md` states the mechanism, the options considered, the
      shared-package-or-convention choice with its reason, and the measured cost.
- [ ] AC-2 Tracked is known at compile time; an untracked `set` emits nothing; a tracked `set` emits
      exactly its event on every write; tests show each.
- [ ] AC-3 The cost table: hand-written against store, untracked and tracked, created and overwritten
      slots; the store adds nothing measurable beyond the event, or the difference is explained.
- [ ] AC-4 The quest definition in the arcade layout (`models/definition.cairo`, `models/index.cairo`,
      `events/`, `store.cairo`), with scoped names, its assert impl and its errors; no new free
      function without a written reason.
- [ ] AC-5 Every test has a budget; `scripts/gas.py packages/quest --check` (and for a new package)
      passes; the worst calls of `quiver_quest` not raised beyond noise.
- [ ] AC-6 The pull request's CI is green.

## Verification
`scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml build`,
`cd packages/quest && snforge test`, `scripts/gas.py packages/quest --check`,
`scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml fmt --check`; the same for a new
package; `python3 .github/ci/check-links.py`; then `gh pr checks <n> --watch --interval 30`.

## Report
`REPORT.md` (COMMON.md §6): the mechanism in a paragraph, **the path of the reference model** (the
file the owner will read), the cost table, deviations, escalations. Branch
`feat/ARC-06-model-store`; pull request `[Opus 5.5] ARC-06 model and store pattern`. Foreground only;
your turn ends when `REPORT.md` is written.
