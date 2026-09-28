# ARC-01 audit — the analysis of `quest` and `achievement`, and the proposed API

## Agent
Title: `[GPT-6-Sol] Audit ARC-01 design and quality` · Model: `gpt-6-sol`, reasoning high ·
Profile: `audit` (codex, read-only sandbox). You cannot write files: your final message is
your report.

## What you audit
`docs/research/ARC-01-quest-achievement.md` in your working directory (pull request #2), the
deliverable of the brief `docs/briefs/ARC-01-quest-achievement.md`. Read the brief first: it
is the specification. You receive the deliverable and the specification, not the author's
reasoning.

Sources, read-only, in your working directory:
- `ref/arcade/`: `cartridge-gg/arcade` at `c53fadc`; the report cites
  `ref/arcade/packages/<quest|achievement>/…` as `quest/…` and `achievement/…`.
- `ref/grimworld/`: the game's documents at `e8a6a72` (ADR-0004, ADR-0007,
  `docs/needs/arcade.md`, design/06, 13, 14, `docs/briefs/ORCH-quiver.md`, PLAN).
- `docs/CAIRO.md`, `docs/briefs/COMMON.md`, `PLAN.md`.

## Lenses
Design conformance and quality (the game's OPERATIONS §6), on a document that will be
accepted by the owner as the API of two packages. Check, with evidence:

1. **Fidelity to the source.** Sample at least ten citations across §1 and §2, including
   every defect D-1 to D-4 and at least three of D-5 to D-14: does the code at the cited
   lines say what the report says? Is each defect's scenario real (walk it through the
   code)? Is any behaviour of the Dojo packages missing from §1 that an implementer needs?
2. **The proposed API (§3).** Is it complete and implementable as written: every function,
   entrypoint, hook and event with a signature; storage layouts whose bit ranges add up and
   fit a `felt252` (< 2^251); bounds stated for every loop. Does the storage-mode progress
   algorithm (§3.5) implement the stated semantics in every case: lazy prerequisites, the
   `unlocked` cache, the accept step across intervals of a recurring quest, saturation,
   completion once per interval, claim? Are there states the algorithm can reach that the
   report does not describe?
3. **Access control (§3.6).** Can a caller who is not a registered reporter, not the admin,
   or not authorised for a `player_id` change any state through the external ABI? Is the
   boundary between the trusted internal layer and the external layer clear enough that a
   consumer cannot expose the internals by mistake?
4. **The game's needs (§4).** Is each of A-1 to A-9 (`ref/grimworld/docs/needs/arcade.md`)
   truly met by the API, or only claimed? Check the design rules the report assigns to the
   game (design/06, 13, 14).
5. **Cost (§5).** Do the read and write counts follow from the layouts and the algorithm?
   Is the worst case the true worst case? Does the proposal respect `docs/CAIRO.md` (one
   write per record per call, packing, no `u256`, arithmetic before loops)?
6. **Bounds and lifetime.** Bounds such as 28 quests per task and no removal or retirement
   of a quest: what happens over the life of a game that keeps adding quests on the same task?
7. **Workspace and CI (§6)**, and the open questions (§7): is any question missing that the
   owner must decide before ARC-02 and ARC-03 start?

## Report
Your final message, in this form (the game's OPERATIONS §6):

```markdown
# [GPT-6-Sol] Audit — ARC-01 — design and quality

## Verdict
PASS | PASS WITH FINDINGS | FAIL

## Findings
| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |

## Coverage
What was reviewed, what was not, and why.
```

Severities: `blocker` (the API is unsound or a rule is broken), `major` (wrong in a reachable
case; a claim of the report contradicted by the source; a need claimed but not met), `minor`
(clarity, completeness, cost), `note`. Every finding needs evidence: a file and line, a
scenario, or a quoted rule.
