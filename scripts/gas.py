#!/usr/bin/env python3
"""Gas tool of a Cairo package: measures each snforge test and checks its budget.

Usage: scripts/gas.py <package dir> [--check | --write]

Runs `snforge test` in the package, reads each test's measured L2 gas from snforge's output and
its budget from `#[available_gas(l2_gas: N)]` in the sources (src/ and tests/), then
  --write  rewrites the package's GAS.md: test, measured, budget, date, commit;
  --check  (the default) fails, naming the test, when a test has no budget, when its budget is
           below the measured value or above ceil(1.05 * measured); it also fails when GAS.md
           disagrees with the measured values.

Exit codes: 0 success, 1 a failed check, 2 a usage error. Standard library only.
"""

import datetime
import pathlib
import re
import subprocess
import sys

TOLERANCE_NUM, TOLERANCE_DEN = 105, 100  # budget <= ceil(1.05 * measured), in integers

PASS_RE = re.compile(r"^\[PASS\]\s+(\S+)\s+\(.*?\bl2_gas:\s*~?(\d+)\)", re.M)
FAIL_RE = re.compile(r"^\[FAIL\]\s+(\S+)", re.M)
# An attribute list, then the function it decorates: `#[test] #[available_gas(l2_gas: N)] fn name`.
TEST_FN_RE = re.compile(r"((?:[ \t]*#\[[^\n]*\][ \t]*\n)+)[ \t]*(?:pub\s+)?fn\s+(\w+)")
BUDGET_RE = re.compile(r"#\[available_gas\(\s*l2_gas:\s*(\d+)\s*\)\]")
ROW_RE = re.compile(r"^\|\s*`([^`]+)`\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|", re.M)


def parse_snforge_output(text):
    """Returns ({test path: measured l2 gas}, [failed test paths]) from `snforge test` output."""
    measured = {name: int(gas) for name, gas in PASS_RE.findall(text)}
    failed = FAIL_RE.findall(text)
    return measured, failed


def parse_budgets(source):
    """Returns {fn name: budget or None} for every `#[test]` function of a Cairo source."""
    budgets = {}
    for attrs, name in TEST_FN_RE.findall(source):
        if "#[test]" not in attrs:
            continue
        found = BUDGET_RE.search(attrs)
        budgets[name] = int(found.group(1)) if found else None
    return budgets


def ceil_margin(measured):
    """ceil(1.05 * measured), the highest budget accepted (docs/CAIRO.md §2)."""
    return -(-measured * TOLERANCE_NUM // TOLERANCE_DEN)


def short_name(path):
    """`pkg_integrationtest::module::test` -> `module::test`."""
    return path.split("::", 1)[1] if "::" in path else path


def budget_of(path, budgets):
    return budgets.get(path.rsplit("::", 1)[-1])


def check(package, measured, budgets, table):
    """Returns the list of problems (empty when the package passes)."""
    problems = []
    for path in sorted(measured):
        gas, budget = measured[path], budget_of(path, budgets)
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
        name = short_name(path)
        want = (measured[path], budget_of(path, budgets))
        if name not in recorded:
            problems.append(f"{package}: {name} is missing from GAS.md")
        elif recorded[name] != want:
            problems.append(
                f"{package}: {name} GAS.md says measured/budget {recorded[name]}, now {want}"
            )
    known = {short_name(path) for path in measured}
    for name in sorted(set(recorded) - known):
        problems.append(f"{package}: GAS.md lists {name}, which is no longer measured")
    return problems


def parse_table(markdown):
    """Returns [(test, measured, budget)] from the rows of a GAS.md."""
    return [(name, int(gas), int(budget)) for name, gas, budget in ROW_RE.findall(markdown)]


def render(package, measured, budgets, date, commit):
    lines = [
        f"# Gas of `{package}`",
        "",
        "Produced by `scripts/gas.py --write`; checked by `scripts/gas.py --check`. Measured is the",
        "L2 gas snforge reports for the test; the budget is its `#[available_gas(l2_gas: N)]`,",
        "`N = ceil(1.05 x measured)` (docs/CAIRO.md §2).",
        "",
        "| Test | Measured (l2_gas) | Budget (l2_gas) | Date | Commit |",
        "|---|---|---|---|---|",
    ]
    for path in sorted(measured):
        lines.append(
            f"| `{short_name(path)}` | {measured[path]} | {budget_of(path, budgets)} "
            f"| {date} | {commit} |"
        )
    return "\n".join(lines) + "\n"


def read_budgets(package_dir):
    budgets = {}
    for path in sorted(package_dir.rglob("*.cairo")):
        if "target" in path.relative_to(package_dir).parts:
            continue
        budgets.update(parse_budgets(path.read_text()))
    return budgets


def git_commit():
    out = subprocess.run(["git", "rev-parse", "--short", "HEAD"], capture_output=True, text=True)
    return out.stdout.strip() or "unknown"


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
        ["snforge", "test"], cwd=package_dir, capture_output=True, text=True
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
    budgets = read_budgets(package_dir)
    gas_md = package_dir / "GAS.md"
    if flags == ["--write"]:
        gas_md.write_text(
            render(
                package,
                measured,
                budgets,
                datetime.datetime.now(datetime.timezone.utc).date().isoformat(),
                git_commit(),
            )
        )
        print(f"{package}: wrote {gas_md} ({len(measured)} tests)")
        return 0
    table = parse_table(gas_md.read_text()) if gas_md.is_file() else []
    problems = check(package, measured, budgets, table)
    for problem in problems:
        print(problem, file=sys.stderr)
    if problems:
        return 1
    print(f"{package}: {len(measured)} tests within budget, GAS.md up to date")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
