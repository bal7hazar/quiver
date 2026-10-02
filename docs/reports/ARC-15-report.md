# [Sonnet 5.5] ARC-15 — cancel superseded PR runs

## Summary
`cairo.yml` and `tooling.yml` now group by workflow and PR on `pull_request` events with
`cancel-in-progress: true`; every other event gets a group unique to the run
(`github.run_id`), so nothing on main, schedule, dispatch or tag is cancelled or replaced.
Pull request: #45.

## Files changed
- `.github/workflows/cairo.yml`: `concurrency:` block and its comment.
- `.github/workflows/tooling.yml`: new `concurrency:` block and comment.
- `docs/reports/ARC-15-report.md`: this report.

## Commands run
- `scripts/prepush.sh`: python unit tests OK, links OK, fmt/build skipped (no Cairo input), OK.
- `git push -u origin HEAD`, `gh pr create --base main` (#45).

## Notes
Through `workflow_call` from `release.yml` (a tag push), `github.workflow` is `release` and
`github.event_name` is `push` (the caller's), so the group is `release-run-<run_id>` and
`cancel-in-progress` is false; `release.yml` has no concurrency of its own, so there is no clash.

## Deviations from the task
None.

## Escalations
None.
