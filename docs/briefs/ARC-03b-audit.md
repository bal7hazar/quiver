# ARC-03b audit — the `quiver_quest` component

## Agent
Title: `[GPT-6-Astra] Audit ARC-03b security and cost` · Model: `gpt-6-astra`, reasoning high
· Profile: `audit` (codex, read-only sandbox). You cannot write files: your final message is
your report.

## What you audit
Pull request #7, checked out in your working directory: `packages/quest/src/component.cairo`,
`packages/quest/src/interface.cairo`, `packages/quest/tests/**`, `packages/quest/README.md`,
`packages/quest/CHANGELOG.md`, `packages/quest/GAS.md`, `docs/BUDGETS.md`, the deliverable of
`docs/briefs/ARC-03b-quest-component.md`. Read the brief first: it is the specification, with
`docs/research/ARC-01-quest-achievement.md` §3.3 to §3.8 and §5.1 (the accepted API),
`docs/decisions/2026-09-28-A-G1-api.md` (the game's answers: A-10, A-11) and `docs/CAIRO.md`.
The library `packages/quest/src/logic/` was audited separately (ARC-03a, reports in
`docs/reports/`); audit how the component uses it. You receive the deliverable and the
specification, not the author's reasoning. This is the package the game will call from its
persistent contract to record quests and pay their rewards.

## Lenses
Security, access control and ownership first; then design conformance and cost (the game's
OPERATIONS §2: access control and ownership are always audited). Check, with evidence:

1. **Access control.** Through the external ABI (`IQuest`), can a caller who is not the admin
   define, retire or set a reporter; can a caller who is not a registered reporter report
   progress; can a caller not authorised for a `player_id` accept, abandon or claim for it?
   Can a reporter do anything beyond progress? Is the internal layer reachable from the ABI
   when the consumer does not expose it? Is a revoked reporter refused at once?
2. **State machine.** Can a player complete a quest twice in one interval, claim twice, claim
   what is not completed, progress a locked, inactive, retired or unaccepted quest, keep an
   acceptance past rollover (A-11), or unlock a quest whose prerequisites are not met? Can a
   quest be retired while a live quest depends on it (Q-20), or `live_dependents` underflow or
   overflow? Can definitions be overwritten?
3. **Hooks and re-entrancy.** State is written before every hook; a hook that re-enters the
   component (progress, claim, accept) sees a consistent state and cannot double-count or
   double-claim; a hook that panics reverts the whole call.
4. **Algorithms.** Are `progress_many`, `accept`, `abandon`, `claim`, `retire` and `define`
   those of §3.5 step by step: reads limited to what a step needs, a quest-level reason skips
   and never reverts, one write per record per call, `Mode::Event` reads and writes nothing?
   Judge the deviations the author declares (a progress record written only when its counts
   change; `quest_current_interval` returning `None` for an undefined quest).
5. **Events.** Contents and keys as §3.4; nothing the indexer needs is missing, nothing is
   emitted that §3.4 does not list.
6. **Cost.** Benchmarks on every worst case of §5.1; budgets within 5%; `docs/BUDGETS.md`
   matches `GAS.md`. The author measures the worst `progress_many` at about 704 M L2 gas for
   the component alone: compare it with Starknet's per-transaction limits as you know them
   (say which figure you use and its source), and say whether the package must document a
   practical bound below the accepted one.
7. **Tests.** Every named test case of ARC-01 §2 for `quest` exists (here or in ARC-03a) and
   would fail if its rule were broken; the mock consumers do not hide a defect (a mock that
   authorises everyone where a test needs refusal).

## Report
Your final message, in this form (the game's OPERATIONS §6):

```markdown
# [GPT-6-Astra] Audit — ARC-03b — security and cost

## Verdict
PASS | PASS WITH FINDINGS | FAIL

## Findings
| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |

## Coverage
What was reviewed, what was not, and why.
```

Severities: `blocker` (a caller gains what the rules forbid; state corrupted), `major` (wrong
in a reachable case; a rule without a test that could fail), `minor`, `note`. Every finding
needs evidence: a file and line, a scenario, or a quoted rule.
