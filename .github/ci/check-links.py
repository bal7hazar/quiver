#!/usr/bin/env python3
"""Check the relative links of every tracked Markdown file.

A link `[text](path)` or `[text](path#anchor)` that is not a URL must point at a tracked file or
folder of the repository, and its anchor, when it points into a Markdown file, at one of that
file's headings (GitHub's slug rules, simplified: lower case, punctuation dropped, spaces to
hyphens). URLs (http, https, mailto) are not fetched: CI stays offline and fast.
"""

import os
import re
import subprocess
import sys

LINK = re.compile(r"(?<!!)\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
FENCE = re.compile(r"^\s*(```|~~~)")


def tracked():
    out = subprocess.run(["git", "ls-files", "-z"], check=True, capture_output=True).stdout
    return [p for p in out.decode().split("\0") if p]


def slug(heading):
    s = heading.strip().lower()
    s = re.sub(r"[`*_~]", "", s)
    s = re.sub(r"[^\w\- ]", "", s)
    return s.replace(" ", "-")


def anchors(path, cache={}):
    if path not in cache:
        found, fenced = set(), False
        with open(path, encoding="utf-8") as f:
            for line in f:
                if FENCE.match(line):
                    fenced = not fenced
                elif not fenced and line.startswith("#"):
                    found.add(slug(line.lstrip("#")))
        cache[path] = found
    return cache[path]


def main():
    files = tracked()
    present = set(files)
    dirs = {os.path.dirname(p) for p in files}
    for p in list(dirs):
        while p:
            p = os.path.dirname(p)
            dirs.add(p)
    errors = []
    for md in (p for p in files if p.endswith(".md")):
        fenced = False
        with open(md, encoding="utf-8") as f:
            for n, line in enumerate(f, 1):
                if FENCE.match(line):
                    fenced = not fenced
                    continue
                if fenced:
                    continue
                for target in LINK.findall(line):
                    if re.match(r"^[a-z][a-z0-9+.-]*:", target):
                        continue
                    path, _, anchor = target.partition("#")
                    if path:
                        resolved = os.path.normpath(os.path.join(os.path.dirname(md), path))
                    else:
                        resolved = md
                    if resolved.startswith(".."):
                        errors.append(f"{md}:{n}: {target}: outside the repository")
                        continue
                    if resolved not in present and resolved.rstrip("/") not in dirs:
                        errors.append(f"{md}:{n}: {target}: no such file")
                        continue
                    if anchor and resolved.endswith(".md") and slug(anchor) not in anchors(resolved):
                        errors.append(f"{md}:{n}: {target}: no such heading")
    for e in errors:
        print(e, file=sys.stderr)
    print(f"check-links: {len(errors)} broken link(s)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
