# PR-8 audit — the launch lock and the agent budget in the launcher

## Agent
Title: `[GPT-6-Sol] Audit PR-8 launcher lock` · Model: `gpt-6-sol`, reasoning high · Profile:
`audit` (codex, read-only sandbox). You cannot write files: your final message is your report.

## What you audit
Pull request #8, checked out in your working directory: the changes to `scripts/agent.sh` and
`.github/workflows/tooling.yml` against `origin/main` (`git diff origin/main -- scripts .github`).
The reference it ports is `bal7hazar/grimworld#48` (the game's launcher); the rule is the
game's OPERATIONS §3: at most 3 Grim World agents at a time across the game, the map library
and `quiver`, codex audits included; the count and the start of a launch under the shared lock
`~/orchestrator/agent-launch.lock`, taken by the three launchers.

## Lenses
Security and quality of tooling. Check, with evidence:

1. Can two launches (of this launcher, or of this one and another that takes the same lock)
   both pass the count and start a third and a fourth agent? Is the lock held from the count
   to the start of the unit or the detached process, and released for the agent?
2. Does the count fail closed in every way it can fail (systemctl, pgrep, unreadable `/proc`,
   a pid file with garbage, a reused pid)? Can it over-count so that no launch is ever possible,
   or under-count a codex audit, a resumed codex audit, or a claude unit that is activating?
3. Is a claude agent ever started detached (outside a unit) now?
4. Do the CI tests exercise these paths, and would they fail if the lock or the count were
   removed?

## Report
Your final message, in the audit form of the game's OPERATIONS §6 (`# [GPT-6-Sol] Audit — PR-8 —
launcher lock`, Verdict, Findings table with severity, location, finding, evidence, fix,
Coverage). Every finding needs evidence: a file and line, or a scenario.
