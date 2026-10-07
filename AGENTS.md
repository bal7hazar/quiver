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
changed paths (ARC-18); `scripts/prepush.sh` is scoped by changed paths too. Unit tests live in
their modules (D-167); `tests/` holds only what deploys a contract. On the VPS, `snforge` and
`scarb` go through the machine's shims, and `scripts/lock.sh snforge test` takes the project and
heavy locks.

| Part | Local test command | Memory peak |
| --- | --- | --- |
| `packages/quest` (`quiver_quest`, 513 tests) | `cd packages/quest && snforge test [<filter>]` | never measured: measure first |
| `packages/achievement` (`quiver_achievement`, 147 tests) | `cd packages/achievement && snforge test [<filter>]` | never measured: measure first |
| `packages/leaderboard` (`quiver_leaderboard`, 78 tests) | `cd packages/leaderboard && snforge test [<filter>]` | 1.0 GB (1 022 620 kB, first full run, ARC-05a; the 1,000-submission benchmark alone 0.88 GB) |
| `scripts/` (Python) | `python3 -m unittest scripts/test_gas.py`; `python3 -m unittest scripts/test_hook.py` (outside prepush's discovery, to avoid recursion) | no Cairo build |
| `.github/ci/` (Python) | `python3 -m unittest discover -s .github/ci -p "test_*.py"` | no Cairo build |

No Node package exists here. A Cairo suite whose peak is unknown is run "measure first": capped
(`prlimit --as=8589934592 -- /usr/bin/time -v snforge test ...`) or on the Mac, never uncapped on
the VPS; the next lot that runs one records its peak here.

The gas check, `python3 scripts/gas.py packages/<pkg> --check` (Linux only), runs the package's
whole snforge suite single-threaded (D-176). It is a pin check, not "the tests of the part
touched": run it only when that package's `src/`, `tests/`, `Scarb.toml`, `Scarb.lock`,
`.tool-versions` or `GAS.md` change, and a brief names it separately.

The pre-push hook stays minimal (2026-10-02 rule) and is not a substitute for the scoped tests.
