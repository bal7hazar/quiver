# ARC-04 audit — `quiver_achievement` 0.1.0, event mode only

## Agent
Title: `[GPT-6-Astra] Audit ARC-04 security and cost` · Model: `gpt-6-astra`, reasoning high ·
Profile: `audit` (codex, read-only sandbox). You cannot write files: your final message is your
report.

## What you audit
Pull request #17, checked out in your working directory: `packages/achievement/**`,
`docs/BUDGETS.md` (achievement section) and the amended achievement parts of
`docs/research/ARC-01-quest-achievement.md`. The specification: `docs/briefs/ARC-04-achievement.md`
and the decision `docs/decisions/2026-09-29-achievement-event-only.md` (read them from `origin/main`
with `git show origin/main:<path>` if they are not in your checkout), `docs/CAIRO.md`. The model the
package follows is `packages/quest/` (`quiver_quest` 0.1.0, published, audited: `docs/reports/`).
This package will be published; its layout is frozen at 0.1.0.

## Lenses
Security and access control first (the project manager's condition); then conformance to the
decision, packing and cost. Check, with evidence:

1. **Access control.** Through `IAchievement`, can a caller who is not the admin define, retire or
   set a reporter; can a caller who is not a registered reporter emit progress; is a revoked reporter
   refused at once; is the internal layer unreachable from the ABI unless the consumer exposes it?
   Can a reporter do anything beyond progress?
2. **Event mode only, by absence** (the decision's first condition): is there any path, type or
   entrypoint by which a consumer could ask for storage mode, store per-player data, complete or
   claim? Is anything reserved in the layout for a later storage design (it must not be)?
3. **Definitions.** Validation (id, 1 to 3 tasks, totals, window, repeated tasks), no redefinition,
   retirement (once, of a defined achievement), the events emitted and their keys; the packing
   (field widths, reserved bits, presence bits, an empty slot, every value below 2^251).
4. **Progress.** The batch bound of 16 counted before merging, duplicates merged with saturation,
   zeros dropped, task id 0 rejected; exactly one `AchievementProgressed` per merged non-zero entry;
   nothing read or written per player. The author notes that progress on a task no live achievement
   uses still emits an event: judge whether that is acceptable for 0.1.0 and documented.
5. **Cost.** The worst `progress_many` and the game's use measured under 20M L2 gas; budgets within
   5 %. The author notes that defining the game's 26 title tiers in one transaction costs about 18.5M
   (no single call above 1.2M): judge whether the README's advice is enough.
6. **Tests.** The named `achievement_` cases kept exist and could fail; the dropped ones are dropped
   for the decision's reason only.

## Report
Your final message, in the audit form of the game's OPERATIONS §6 (`# [GPT-6-Astra] Audit — ARC-04 —
security and cost`, Verdict, Findings table with severity, location, finding, evidence, fix,
Coverage). Severities: `blocker`, `major`, `minor`, `note`. Every finding needs evidence.
