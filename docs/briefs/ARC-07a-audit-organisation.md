# ARC-07a audit — organisation (docs/CAIRO.md §8)

## Agent
Title: `[GPT-6-Sol] Audit ARC-07a organisation` · Model: `gpt-6-sol`, reasoning high · Profile:
`audit` (codex, read-only sandbox). Your final message is your report.

## What you audit
Pull request #20, checked out in your working directory: `quiver_quest` 0.2.0 rewritten on the
pattern of the owner's rule D-143, after the owner's review of ARC-06 (D-147: `logic/` removed; each
model's event optional for the consumer). The specification: `docs/briefs/ARC-07a-quest-0.2.0.md`
(read with `git show origin/main:docs/briefs/ARC-07a-quest-0.2.0.md`), `docs/CAIRO.md` §7 and §8,
`docs/research/ARC-06-model-store.md` (the pattern, §6 the classification of models, §7 optional
tracking). The arcade reference is in `ref/arcade/packages/quest/src/` of your working directory.
The owner will review this lot as ARC-06.

## Lens: organisation (§8)
1. No `logic/`; the layers of §7 (`models/` one file per entity in arcade's shape, `types/`,
   `helpers/`, `events/`, one store, the component: entrypoints and access control only). Nothing
   stored outside a model; nothing read or written outside the store.
2. No free function without a written reason (one is declared: judge it).
3. Every tracked model emits on every write under `TrackAll` and nothing under `TrackNone`; untracked
   models never; action events (`QuestCompleted`, `QuestClaimed`, …) emitted where 0.1.0 emits them and
   never duplicated by a model's event. The tests that show each.
4. Names short, scoped, the design's words; `QuestDefinition` is the model only.
5. The optional-tracking API from the consumer's side (the README sketch): is the choice clear, made
   at compile time, and safe by default?
6. Behaviour of 0.1.0 kept: events, error strings, storage layouts, views.

## Report
In the audit form of the game's OPERATIONS §6 (`# [GPT-6-Sol] Audit — ARC-07a — organisation`,
Verdict, Findings, Coverage).
