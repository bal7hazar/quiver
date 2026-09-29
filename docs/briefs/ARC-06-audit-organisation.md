# ARC-06 audit — organisation (docs/CAIRO.md §8)

## Agent
Title: `[GPT-6-Sol] Audit ARC-06 organisation` · Model: `gpt-6-sol`, reasoning high · Profile:
`audit` (codex, read-only sandbox). Your final message is your report.

## What you audit
Pull request #19, checked out in your working directory: the model-and-store pattern of the owner's
rule D-143 and its reference implementation on the quest definition. The specification:
`docs/briefs/ARC-06-model-store.md` and `docs/CAIRO.md` §7 and §8 (read from `origin/main` with
`git show origin/main:<path>` if needed); the write-up `docs/research/ARC-06-model-store.md`. The
reference layout is `cartridge-gg/arcade` at `c53fadc`, `packages/quest/src/` (`models/definition.cairo`,
`models/index.cairo`, `store.cairo`, `events/`), cloned read-only in `ref/arcade/` of your working
directory. The owner will judge this one model before the two packages are rewritten on it: the
question is whether it is the owner's pattern.

## Lens: organisation (§8), and fidelity to arcade
1. The layers of §7 in `packages/quest/src/models/`, `events/`, `store.cairo`: the model's struct in
   `models/index.cairo`, its `...Impl of ...Trait` with the constructor and the behaviour, its
   `...Assert` impl, its `errors` module, the event in `events/`, the store's `get_x` and `set_x`.
   Compare with arcade's files one by one: what is kept, what differs, and whether each difference
   is justified by the absence of Dojo.
2. No free function without a written reason (two helpers are declared: judge their reasons).
3. Tracked at compile time; the store emits a tracked model's event on every write and nothing for
   an untracked one; can a tracked model be written without its event, and does anything but a
   convention prevent it?
4. Names short, scoped, the design's words; the two public types named `QuestDefinition` (the new
   model and 0.1.0's first slot) and how ARC-07 should resolve them.
5. The choice of a convention over a shared package: is the reason sound?
6. Is the pattern, as written, one that ARC-07 can apply to every other model of both packages
   (progress, record, held list, reporters; achievement definitions) without exceptions? Name any
   model it would not fit.

## Report
In the audit form of the game's OPERATIONS §6 (`# [GPT-6-Sol] Audit — ARC-06 — organisation`,
Verdict, Findings with severity, location, finding, evidence, fix, Coverage).
