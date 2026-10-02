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
