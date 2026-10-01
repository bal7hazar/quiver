#!/usr/bin/env python3
"""Gas tool of a Cairo package: measures each snforge test and checks its budget.

Usage: scripts/gas.py <package dir> [--check | --write]

Runs `snforge test` in the package (with RAYON_NUM_THREADS=1 unless set, D-176), reads each test's measured L2 gas from snforge's output and
its budget from `#[available_gas(l2_gas: N)]` in the sources (src/ and tests/), then
  --write  rewrites the package's GAS.md: test, measured, budget, date, commit;
  --check  (the default) fails, naming the test, when a test has no budget, when its budget is
           below the measured value or above ceil(1.05 * measured); it also fails when GAS.md
           disagrees with the measured values.

Exit codes: 0 success, 1 a failed check, 2 a usage error. Standard library only.
"""

import datetime
import os
import pathlib
import re
import subprocess
import sys

TOLERANCE_NUM, TOLERANCE_DEN = 105, 100  # budget <= ceil(1.05 * measured), in integers

PASS_RE = re.compile(r"^\[PASS\]\s+(\S+)\s+\(.*?\bl2_gas:\s*~?(\d+)\)", re.M)
FAIL_RE = re.compile(r"^\[FAIL\]\s+(\S+)", re.M)
SUMMARY_RE = re.compile(
    r"^Tests:\s*(\d+) passed,\s*(\d+) failed,\s*(\d+) ignored,\s*(\d+) filtered out", re.M
)
# The tokens that matter to find a test: an attribute list then `fn name`, `mod name {`, braces.
TOKEN_RE = re.compile(
    r"(?P<attrs>(?:[ \t]*#\[[^\n]*\][ \t]*\n)+)[ \t]*(?:pub\s+)?fn\s+(?P<fn>\w+)"
    r"|(?:pub\s+)?mod\s+(?P<mod>\w+)\s*\{"
    r"|(?P<open>\{)|(?P<close>\})"
)
COMMENT_RE = re.compile(r"//[^\n]*")
BUDGET_RE = re.compile(r"#\[available_gas\(\s*l2_gas:\s*(\d+)\s*\)\]")
ROW_RE = re.compile(r"^\|\s*`([^`]+)`\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|", re.M)


def parse_snforge_output(text):
    """Returns ({test path: measured l2 gas}, [failed test paths]) from `snforge test` output."""
    measured = {name: int(gas) for name, gas in PASS_RE.findall(text)}
    failed = FAIL_RE.findall(text)
    return measured, failed


def parse_summary(text):
    """(passed, failed, ignored, filtered out) from snforge's `Tests:` line, or None."""
    found = SUMMARY_RE.findall(text)
    return tuple(int(n) for n in found[-1]) if found else None


def parse_tests(source, prefix):
    """{test path: budget or None, ignored} for every `#[test]` function of a Cairo source.

    `prefix` is the module path of the file as snforge names it (`pkg_integrationtest::mod`);
    inline `mod name { .. }` blocks extend it. The value is (budget or None, is_ignored).
    """
    tests = {}
    stack = []  # for each open brace, the module name it opened, or None
    for token in TOKEN_RE.finditer(COMMENT_RE.sub("", source)):
        if token.group("mod"):
            stack.append(token.group("mod"))
        elif token.group("open"):
            stack.append(None)
        elif token.group("close"):
            if stack:
                stack.pop()
        elif "#[test]" in token.group("attrs"):
            found = BUDGET_RE.search(token.group("attrs"))
            path = "::".join([prefix, *[m for m in stack if m], token.group("fn")])
            tests[path] = (
                int(found.group(1)) if found else None,
                "#[ignore" in token.group("attrs"),
            )
    return tests


def file_prefix(package, package_dir, path):
    """The module path snforge gives the tests of a source file.

    src/a/b.cairo -> `pkg::a::b` (src/lib.cairo -> `pkg`); tests/a.cairo -> `pkg_integrationtest::a`.
    """
    relative = path.relative_to(package_dir)
    root, *rest = relative.with_suffix("").parts
    modules = [] if (root == "src" and rest == ["lib"]) else list(rest)
    return "::".join([package if root == "src" else f"{package}_integrationtest", *modules])


def ceil_margin(measured):
    """ceil(1.05 * measured), the highest budget accepted (docs/CAIRO.md §2)."""
    return -(-measured * TOLERANCE_NUM // TOLERANCE_DEN)


def coverage(package, measured, tests, summary):
    """Problems of completeness: every test of the sources ran and was measured."""
    problems = []
    if summary is None:
        problems.append(f"{package}: no `Tests:` summary in snforge's output")
    elif summary[2] or summary[3]:
        problems.append(
            f"{package}: snforge ignored {summary[2]} and filtered out {summary[3]} tests; "
            "every test must run"
        )
    for path in sorted(set(tests) - set(measured)):
        why = "is #[ignore]d" if tests[path][1] else "has no measured result"
        problems.append(f"{package}: {path} {why}: every test needs a measured budget")
    for path in sorted(set(measured) - set(tests)):
        problems.append(f"{package}: {path} was measured but is not found in the sources")
    return problems


def check(package, measured, tests, table, summary=None):
    """Returns the list of problems (empty when the package passes).

    `measured` is {test path: l2 gas} from snforge; `tests` is {test path: (budget, ignored)}
    from the sources; `table` the rows of GAS.md; `summary` snforge's (passed, failed, ignored,
    filtered out) counts.
    """
    problems = coverage(package, measured, tests, summary)
    for path in sorted(set(measured) & set(tests)):
        gas, budget = measured[path], tests[path][0]
        if budget is None:
            problems.append(f"{package}: {path} has no #[available_gas(l2_gas: N)] budget")
        elif budget < gas:
            problems.append(f"{package}: {path} budget {budget} is below the measured {gas}")
        elif budget > ceil_margin(gas):
            problems.append(
                f"{package}: {path} budget {budget} is above ceil(1.05 x {gas}) = {ceil_margin(gas)}"
            )
    recorded = {name: (gas, budget) for name, gas, budget in table}
    for path in sorted(measured):
        want = (measured[path], tests.get(path, (None, False))[0])
        if path not in recorded:
            problems.append(f"{package}: {path} is missing from GAS.md")
        elif recorded[path] != want:
            problems.append(
                f"{package}: {path} GAS.md says measured/budget {recorded[path]}, now {want}"
            )
    for name in sorted(set(recorded) - set(measured)):
        problems.append(f"{package}: GAS.md lists {name}, which is no longer measured")
    return problems


def parse_table(markdown):
    """Returns [(test, measured, budget)] from the rows of a GAS.md."""
    return [(name, int(gas), int(budget)) for name, gas, budget in ROW_RE.findall(markdown)]


def render(package, measured, tests, date, commit):
    lines = [
        f"# Gas of `{package}`",
        "",
        "Produced by `scripts/gas.py --write`; checked by `scripts/gas.py --check`. Measured is the",
        "L2 gas snforge reports for the test; the budget is its `#[available_gas(l2_gas: N)]`,",
        "set at `ceil(1.05 x measured)` and never above it; a budget kept tighter, between the",
        "measure and that ceiling, also passes (docs/CAIRO.md §2).",
        "",
        "| Test | Measured (l2_gas) | Budget (l2_gas) | Date | Commit |",
        "|---|---|---|---|---|",
    ]
    for path in sorted(measured):
        lines.append(
            f"| `{path}` | {measured[path]} | {tests[path][0]} "
            f"| {date} | {commit} |"
        )
    return "\n".join(lines) + "\n"


def read_tests(package, package_dir):
    tests = {}
    for path in sorted(package_dir.rglob("*.cairo")):
        top = path.relative_to(package_dir).parts[0]
        if top in ("src", "tests"):
            tests.update(parse_tests(path.read_text(), file_prefix(package, package_dir, path)))
    return tests


def git_commit():
    out = subprocess.run(["git", "rev-parse", "--short", "HEAD"], capture_output=True, text=True)
    return out.stdout.strip() or "unknown"


def snforge_env(environ=None):
    """The environment of the snforge run: single-threaded compiler (D-176) unless the caller chose
    a thread count; an empty value is no choice (rayon would use its default) and is pinned too."""
    env = dict(os.environ if environ is None else environ)
    if not env.get("RAYON_NUM_THREADS"):
        env["RAYON_NUM_THREADS"] = "1"
    return env


def main(argv):
    args = [a for a in argv if not a.startswith("--")]
    flags = [a for a in argv if a.startswith("--")]
    if len(args) != 1 or len(flags) > 1 or any(f not in ("--check", "--write") for f in flags):
        print(__doc__, file=sys.stderr)
        return 2
    package_dir = pathlib.Path(args[0])
    if not (package_dir / "Scarb.toml").is_file():
        print(f"{package_dir}: no Scarb.toml", file=sys.stderr)
        return 2
    named = re.search(r'^name\s*=\s*"([^"]+)"', (package_dir / "Scarb.toml").read_text(), re.M)
    package = named.group(1) if named else package_dir.resolve().name
    run = subprocess.run(
        ["snforge", "test"], cwd=package_dir, capture_output=True, text=True, env=snforge_env()
    )
    output = run.stdout + run.stderr
    measured, failed = parse_snforge_output(output)
    if failed or run.returncode != 0 or not measured:
        print(output, file=sys.stderr)
        for path in failed:
            print(f"{package}: {path} failed", file=sys.stderr)
        if not failed:
            print(f"{package}: snforge test failed or ran no test", file=sys.stderr)
        return 1
    tests = read_tests(package, package_dir)
    summary = parse_summary(output)
    gas_md = package_dir / "GAS.md"
    if flags == ["--write"]:
        problems = coverage(package, measured, tests, summary)
        for problem in problems:
            print(problem, file=sys.stderr)
        if problems:
            return 1
        gas_md.write_text(
            render(
                package,
                measured,
                tests,
                datetime.datetime.now(datetime.timezone.utc).date().isoformat(),
                git_commit(),
            )
        )
        print(f"{package}: wrote {gas_md} ({len(measured)} tests)")
        return 0
    table = parse_table(gas_md.read_text()) if gas_md.is_file() else []
    problems = check(package, measured, tests, table, summary)
    for problem in problems:
        print(problem, file=sys.stderr)
    if problems:
        return 1
    print(f"{package}: {len(measured)} tests within budget, GAS.md up to date")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
