# AGENTS.md

Rules for every agent and every person who pushes to `quiver`. The rules of a task are its brief and
[docs/briefs/COMMON.md](docs/briefs/COMMON.md); how the workspace is built and checked is
[docs/WORKSPACE.md](docs/WORKSPACE.md).

## Before every push

- **Run `scripts/prepush.sh` before every push, and never push red.** It checks, against the merge
  base with `origin/main`, what a few seconds to a few minutes can show: the unit tests of the
  scripts, the links, `scarb fmt --check`, `scarb build` of the packages the change affects, and
  `scripts/gas.py --check` of a package whose gas inputs changed (it runs `snforge`, so it can take
  minutes). The full check stays with CI. On the VPS the compile steps wait at most 90 s for the
  machine's build lock and are skipped, with one line, when it stays busy (CI compiles); on a Mac the gas check is skipped (pins are checked on Linux).
- Enable the hook once per clone: `git config core.hooksPath .githooks`. `.githooks/pre-push` then
  runs the script on every `git push`, in every worktree of the clone.
- **Never skip the hook** (`--no-verify`, or unsetting `core.hooksPath`). A red
  step is fixed, not bypassed: regenerate the artefact it names (`scripts/gas.py <package>
  --write`), format (`scarb fmt`), or fix the test.

## How tests are scoped

A thread runs locally only the tests of the parts it touched (and of the packages that depend on
them), never the whole suite at every step. The whole suite is CI's, on the pull request, gated by
changed paths. No part below has a recorded memory peak, so each is "measure first": run it capped
(`prlimit --as=8589934592 -- /usr/bin/time -v <command>`) or on the Mac, never uncapped on the VPS.

| Part | Local test command | Memory peak |
| --- | --- | --- |
| `packages/quest` (`quiver_quest`) | `snforge test -p quiver_quest [<filter>]` | none recorded: measure first, capped or on the Mac |
| `packages/achievement` (`quiver_achievement`) | `snforge test -p quiver_achievement [<filter>]` | none recorded: measure first, capped or on the Mac |
| `scripts/` (Python) | `python3 -m unittest scripts/test_gas.py scripts/test_hook.py` | none recorded (no Cairo build) |
| `.github/ci/` (Python) | `python3 -m unittest discover -s .github/ci -p "test_*.py"` | none recorded (no Cairo build) |

There is no Node package in this repository. The pre-push hook stays minimal (2026-10-02 rule) and
is not a substitute for the scoped tests.
