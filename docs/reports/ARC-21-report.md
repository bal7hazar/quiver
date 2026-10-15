# ARC-21: committed brief text and machine paths removed from the docs

Documents only (nexus #163). A committed task document carries task text only: no rule text of the
organisation's standard, no session brief, no machine paths.

## What changed

- Deleted the successor-orchestrator handover file of 2026-10-01 (a 349-line session brief). The
  handover that matters stays in `docs/handover/orchestrator-quiver-2026-10-01.md`. No link pointed
  to the deleted file (a `git grep` of its name found none).
- Replaced machine paths with neutral wording, changing only those lines:
  - six briefs (`ARC-04`, `ARC-06`, `ARC-07a`, `ARC-07b`, `ARC-09`, `ARC-10`);
  - three reports (`ARC-04`, `ARC-06`, `ARC-07a`);
  - `docs/handover/orchestrator-quiver-2026-10-01.md`;
  - `docs/decisions/2026-10-12-publish-quiver_leaderboard-0.1.1.md`.
- The check of the rest of `docs/`, `README.md`, `STATUS.md` and `PLAN.md` found no other marker.
  `scripts/profiles/*.txt` also name machine paths (permission patterns); they are outside this
  task's allowlist and left unchanged.
