#!/usr/bin/env python3
"""Which Cairo packages a change affects, for .github/workflows/cairo.yml.

  affected.py versions   validates .tool-versions and writes `scarb` and `snforge` to GITHUB_OUTPUT
  affected.py matrix     writes `matrix` (JSON, {"include": [{"dir": "packages/x"}]}) and `any`

`matrix` reads `scarb metadata --format-version 1` (the workspace members and their dependencies)
and the event: on a pull request the files changed since the merge base with the base branch,
on any other event every package. A file under packages/<dir>/ affects that package; the root
Scarb.toml and Scarb.lock, .tool-versions, the Cairo workflows, .github/ci/ and scripts/gas.py
affect all; anything else affects none. Every package that depends, transitively, on an affected
one runs too. A pull request controls all of these inputs, so each value is validated before it
reaches a step: exact versions, package directories of the form packages/<name>, a plain branch
name. Standard library only; the logic is pure functions, tested in test_affected.py.
"""

import json
import os
import pathlib
import re
import subprocess
import sys

ALL_FILES = {
    "Scarb.toml",
    "Scarb.lock",
    ".tool-versions",
    ".github/workflows/cairo.yml",
    ".github/workflows/release.yml",
    "scripts/gas.py",
}
ALL_PREFIXES = (".github/ci/",)
PACKAGE_DIR_RE = re.compile(r"^packages/[a-z0-9][a-z0-9_-]*$")
VERSION_RE = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+$")
BRANCH_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._/-]*$")


def parse_tool_versions(text):
    """Returns {tool: version} from the text of a .tool-versions; an inexact version is an error."""
    versions = {}
    for line in text.splitlines():
        fields = line.split("#")[0].split()
        if not fields:
            continue
        if len(fields) != 2 or not VERSION_RE.match(fields[1]):
            raise ValueError(f".tool-versions: not `tool x.y.z`: {line!r}")
        versions[fields[0]] = fields[1]
    return versions


def package_graph(metadata, root):
    """{package dir: set of the package dirs it depends on}, for the workspace members only.

    `metadata` is the parsed `scarb metadata --format-version 1`; `root` the workspace root.
    """
    root = pathlib.PurePosixPath(root)
    by_id = {p["id"]: p for p in metadata["packages"]}
    dirs = {}
    for member in metadata["workspace"]["members"]:
        manifest = pathlib.PurePosixPath(by_id[member]["manifest_path"])
        dirs[by_id[member]["name"]] = str(manifest.parent.relative_to(root))
    graph = {directory: set() for directory in dirs.values()}
    for member in metadata["workspace"]["members"]:
        package = by_id[member]
        for dependency in package.get("dependencies", []):
            if dependency["name"] in dirs and dependency["name"] != package["name"]:
                graph[dirs[package["name"]]].add(dirs[dependency["name"]])
    return graph


def directly_affected(changed, graph):
    """The package dirs a change touches, or all of them for a change to a shared file."""
    hit = set()
    for path in changed:
        if path in ALL_FILES or path.startswith(ALL_PREFIXES):
            return set(graph)
        for directory in graph:
            if path.startswith(directory + "/"):
                hit.add(directory)
    return hit


def with_dependents(hit, graph):
    """`hit` plus every package that depends on one of them, transitively."""
    result = set(hit)
    grew = True
    while grew:
        grew = False
        for directory, dependencies in graph.items():
            if directory not in result and dependencies & result:
                result.add(directory)
                grew = True
    return result


def affected(changed, graph):
    """The package dirs to run, from the changed paths and the package graph."""
    return with_dependents(directly_affected(changed, graph), graph)


def matrix(dirs):
    """The JSON of the workflow matrix; a directory that is not packages/<name> is refused."""
    for directory in dirs:
        if not PACKAGE_DIR_RE.match(directory):
            raise ValueError(f"not a package directory: {directory!r}")
    return json.dumps({"include": [{"dir": d} for d in sorted(dirs)]}, separators=(",", ":"))


def write_output(name, value):
    line = f"{name}={value}\n"
    path = os.environ.get("GITHUB_OUTPUT")
    if path:
        with open(path, "a") as out:
            out.write(line)
    else:
        sys.stdout.write(line)


def changed_files(base):
    if not BRANCH_RE.match(base) or base.startswith("-"):
        raise ValueError(f"not a branch name: {base!r}")
    out = subprocess.run(
        ["git", "diff", "--name-only", f"origin/{base}...HEAD"],
        capture_output=True, text=True, check=True,
    )
    return out.stdout.splitlines()


def main(argv):
    if argv == ["versions"]:
        versions = parse_tool_versions(pathlib.Path(".tool-versions").read_text())
        for tool, output in (("scarb", "scarb"), ("starknet-foundry", "snforge")):
            if tool not in versions:
                raise ValueError(f".tool-versions has no {tool}")
            write_output(output, versions[tool])
        return 0
    if argv == ["matrix"]:
        raw = subprocess.run(
            ["scarb", "metadata", "--format-version", "1", "--no-deps"],
            capture_output=True, text=True, check=True,
        ).stdout
        metadata = json.loads(raw)
        graph = package_graph(metadata, metadata["workspace"]["root"])
        if os.environ.get("GITHUB_EVENT_NAME") == "pull_request":
            dirs = affected(changed_files(os.environ["GITHUB_BASE_REF"]), graph)
        else:
            dirs = set(graph)
        write_output("matrix", matrix(dirs))
        write_output("any", "true" if dirs else "false")
        print(f"packages to run: {sorted(dirs)}")
        return 0
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
