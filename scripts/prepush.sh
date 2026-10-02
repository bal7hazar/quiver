#!/usr/bin/env bash
# Local check to run before every push (ARC-13): what would turn the CI red for a reason a few
# seconds to a couple of minutes can show. The hook .githooks/pre-push runs it; run it by hand too.
# Never push red, never skip the hook. The full check stays with CI (snforge test of every
# affected package, the shellcheck and launcher jobs of tooling.yml, the dependents' builds).
#
#   scripts/prepush.sh [<tag>...]
#
# The change is what differs from the merge base with origin/main: the commits, the working tree
# and the untracked files (so a change can be checked before it is committed). Steps, cheapest
# first, the first failure stops the run (exit 1, naming the step):
#   1. unit tests of the Python scripts (scripts/test_gas.py, .github/ci/test_*.py);
#   2. relative links of the Markdown files (.github/ci/check-links.py);
#   3. scarb fmt --check, the whole workspace;
#   4. scarb build, single-threaded (D-176: RAYON_NUM_THREADS=1, one commit gives one program),
#      of each package the change affects and of its dependents (.github/ci/affected.py);
#   5. scripts/gas.py <package> --check, only for a package whose gas inputs changed: its src/
#      or tests/, its Scarb.toml, or the root Scarb.toml, Scarb.lock or .tool-versions
#      (the inputs of a dependency count too). THIS RUNS snforge AND CAN TAKE MINUTES (it also
#      waits for the machine's heavy lock); a change to the sources of a package is the case it
#      exists for. The full check, every package on every event, stays with CI.
#   6. release_check.py for each <tag> given (the hook passes the quiver_*-v* tags being pushed).
#      The release check needs a tag to check, and a tag derived from the manifest would only
#      compare the manifest with itself and fail every ordinary change whose version is ahead of
#      its changelog, so it runs for a pushed tag only.
# Steps 3 to 5 run scarb: they are skipped altogether, scarb metadata included, when no Cairo input
# changed (a .cairo file, any Scarb.toml, Scarb.lock, .tool-versions). The compile steps (4 and 5)
# run through the VPS's locks, waiting at most 90 s for them (compile_lock below); when they stay
# busy, steps 4 and 5 are skipped with one line and CI compiles. fmt (3) takes no lock. Pins are
# checked on Linux only: on another system step 5 prints "gas: skipped" (CI checks it).
# A change to scripts/gas.py, or to a GAS.md alone, gets its gas check from CI, not from this script.
# Output: each step's name, OK or FAIL and its time; the log of a failed step; the total time.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
# A git hook runs with GIT_DIR, GIT_INDEX_FILE... exported; the tests build repositories of their
# own and would write to this one's index. This clears them; the script finds the repository by cwd.
for var in $(git rev-parse --local-env-vars); do unset "$var"; done

start=$SECONDS
logdir=target/prepush
mkdir -p "$logdir"
log="$logdir/step.log"
trap 'rm -f "$log"' EXIT

fail() {
  echo "prepush: FAIL: $1 ($((SECONDS - start))s)" >&2
  exit 1
}

# step <name> <command...>: runs the command, shows its output only when it fails.
step() {
  local name=$1 began=$SECONDS
  shift
  printf '%-40s' "$name"
  if "$@" > "$log" 2>&1 < /dev/null; then
    echo "OK    $((SECONDS - began))s"
  else
    echo "FAIL  $((SECONDS - began))s"
    sed 's/^/    | /' "$log" >&2
    fail "$name"
  fi
}

# The VPS serialises every Cairo compile behind two locks (scripts/lock.sh): the project lock, then the
# machine-wide heavy lock the scarb/snforge shims take. A Mac has neither (no flock, no shim), and only
# Linux is a machine with that lock. compile_lock takes both, in that order, waiting 90 s in all, and
# keeps them (open file descriptors) until the script exits; the compile steps run under them, so the
# shim sees the heavy lock held by an ancestor. It fails when the VPS is busy: the compile steps are
# then skipped (CI compiles) and the script goes on. fmt and scarb metadata take no lock.
LOCK_WAIT=90
have_lock=0
if [ "$(uname -s)" = Linux ] && command -v flock > /dev/null; then have_lock=1; fi
compile_lock() {
  [ "$have_lock" = 1 ] || return 0
  local deadline=$((SECONDS + LOCK_WAIT)) project heavy
  project=${QUIVER_BUILD_LOCK:-/tmp/quiver-build.lock}
  heavy=${HEAVY_BUILD_LOCK:-$HOME/orchestrator/heavy-build.lock}
  mkdir -p "$(dirname "$heavy")"
  if [ -z "${QUIVER_BUILD_LOCK_HELD:-}" ]; then
    exec {project_fd}>> "$project"
    flock -w "$LOCK_WAIT" "$project_fd" || return 1
  fi
  if [ -z "${HEAVY_BUILD_LOCK_HELD:-}" ]; then
    exec {heavy_fd}>> "$heavy"
    flock -w "$((deadline - SECONDS > 1 ? deadline - SECONDS : 1))" "$heavy_fd" || return 1
  fi
  export QUIVER_BUILD_LOCK_HELD=1 HEAVY_BUILD_LOCK_HELD=1
}

git rev-parse --verify --quiet origin/main > /dev/null \
  || fail "no origin/main to compare with (git fetch origin main)"
base=$(git merge-base origin/main HEAD)
changed=$( { git diff --name-only --no-renames "$base"; git ls-files --others --exclude-standard; } | sort -u)
echo "prepush: base ${base:0:8}, $(grep -c . <<< "$changed" || true) file(s) changed"

step "python unit tests" bash -c '
  python3 -m unittest scripts/test_gas.py &&
  python3 -m unittest discover -s .github/ci -p "test_*.py"'
step "links" python3 .github/ci/check-links.py

cairo=0
grep -Eq '(\.cairo$|(^|/)Scarb\.toml$|^Scarb\.lock$|^\.tool-versions$)' <<< "$changed" && cairo=1

plan=""
if [ "$cairo" = 1 ]; then
step "fmt (workspace)" scarb fmt --check

# The packages to build, and those whose gas inputs changed, from affected.py's own logic.
plan=$(CHANGED="$changed" python3 - <<'PY'
import json, os, subprocess, sys
sys.path.insert(0, ".github/ci")
import affected

changed = os.environ["CHANGED"].split("\n")
raw = subprocess.run(["scarb", "metadata", "--format-version", "1", "--no-deps"],
                     capture_output=True, text=True, check=True).stdout
meta = json.loads(raw)
graph = affected.package_graph(meta, meta["workspace"]["root"])
ROOT_INPUTS = {"Scarb.toml", "Scarb.lock", ".tool-versions"}

def gas_input(path):
    return path in ROOT_INPUTS or any(
        path in (f"{d}/Scarb.toml", f"{d}/GAS.md") or path.startswith((f"{d}/src/", f"{d}/tests/"))
        for d in graph)

for d in sorted(affected.affected(changed, graph)):
    print("build", d)
for d in sorted(affected.affected([p for p in changed if gas_input(p)], graph)):
    print("gas", d)
PY
) || fail "which packages the change affects (affected.py, scarb metadata)"
else
  echo "fmt/build skipped (no Cairo input changed)"
fi

compile=0
grep -Eq '^(build|gas) ' <<< "$plan" && compile=1
if [ "$compile" = 1 ] && ! compile_lock; then
  compile=0
  echo "build/gas: skipped, the VPS build lock was busy for ${LOCK_WAIT} s; CI will compile"
fi

if [ "$compile" = 1 ]; then
while read -r kind dir; do
  [ "$kind" = build ] || continue
  RAYON_NUM_THREADS=1 step "build $dir" nice -n 10 scarb --manifest-path "$dir/Scarb.toml" build
done <<< "$plan"
fi
if [ "$cairo" = 1 ] && ! grep -q '^build ' <<< "$plan"; then echo "build                                   skipped (no package affected)"; fi

if [ "$compile" = 1 ] && grep -q '^gas ' <<< "$plan"; then
  if [ "$(uname -s)" != Linux ]; then
    echo "gas: skipped, pins are checked on Linux (CI)"
  else
    echo "gas check: runs snforge, can take minutes under the shared heavy lock; the full check is CI's"
    while read -r kind dir; do
      [ "$kind" = gas ] || continue
      RAYON_NUM_THREADS=1 step "gas $dir (snforge, slow)" python3 scripts/gas.py "$dir" --check
    done <<< "$plan"
  fi
fi
if [ "$cairo" = 1 ] && ! grep -q '^gas ' <<< "$plan"; then echo "gas                                     skipped (no gas input changed)"; fi

for tag in "$@"; do
  step "release check $tag" python3 .github/ci/release_check.py "$tag"
done

echo "prepush: OK ($((SECONDS - start))s)"
