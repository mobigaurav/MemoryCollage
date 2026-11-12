"""Docs check for pull requests (issue #31).

A PR into dev that changes architecture-relevant code must also update the docs and record the
architect's pass in the PR body, or say why no docs change is needed:

    ## Architecture docs
    Sections changed: SYSTEM_DESIGN 4.7, 6.3; ADR 0001
    (or)
    Docs not needed: internal refactor, no change to the API, cloud resources, app services or workflows

  python scripts/check_docs.py --base dev --files changed.txt --body body.md   # exit 1 on failure
"""
from __future__ import annotations

import argparse
import fnmatch
import re
import sys

# Paths whose changes usually alter the API, cloud resources, data flow, build pipelines or app services.
TRIGGERS = [
    "scripts/*",
    ".github/workflows/*",
    "infra/*",
    "services/api/mb_api/*",
    "services/api/schema.sql",
    "services/api/Dockerfile",
    "memory_book/lib/core/config.dart",
    "memory_book/lib/services/*",
    "memory_book/lib/data/*",
    "memory_book/pubspec.yaml",
    "apps/web/vercel.json",
    "apps/web/next.config.ts",
]
DOCS = ["docs/*", "README.md", "AGENTS.md", "memory_book/docs/*", "memory_book/README.md"]
PLACEHOLDER = re.compile(r"^(<.*>|none|n/?a|tbd|-|\.\.\.)?$", re.I)
MIN_REASON = 15


def _match(path: str, patterns: list[str]) -> bool:
    return any(fnmatch.fnmatch(path, p) for p in patterns)


def section(body: str) -> str:
    """Text of the '## Architecture docs' section (up to the next '## ' heading), comments removed."""
    body = re.sub(r"<!--.*?-->", "", body or "", flags=re.S)
    m = re.search(r"^##\s+Architecture docs\s*$(.*?)(?=^##\s|\Z)", body, re.M | re.S | re.I)
    return m.group(1) if m else ""


def _value(text: str, label: str) -> str:
    m = re.search(rf"^\s*[-*]?\s*\**{label}\**\s*:\s*(.*)$", text, re.M | re.I)
    return m.group(1).strip() if m else ""


def evaluate(base: str, head: str, files: list[str], body: str) -> tuple[bool, list[str]]:
    """Return (ok, messages)."""
    files = [f.strip() for f in files if f.strip()]
    if base != "dev":
        return True, [f"PR into {base}: changes were checked when they merged into dev; nothing to check."]
    if head.startswith("dependabot/"):
        return True, ["Dependabot PR: docs check skipped."]
    trig = sorted(f for f in files if _match(f, TRIGGERS))
    if not trig:
        return True, ["No architecture-relevant files changed."]
    docs = sorted(f for f in files if _match(f, DOCS))
    sec = section(body)
    changed = _value(sec, "Sections changed")
    reason = _value(sec, "Docs not needed")
    head_msg = f"Architecture-relevant files changed: {', '.join(trig[:8])}{' ...' if len(trig) > 8 else ''}"
    if reason and not PLACEHOLDER.match(reason) and len(reason) >= MIN_REASON:
        return True, [head_msg, f"Docs not needed (stated): {reason}"]
    errs = [head_msg]
    if not sec:
        errs.append("PR body has no '## Architecture docs' section (see .github/pull_request_template.md).")
    if not docs:
        errs.append("No docs changed (docs/**, README.md or AGENTS.md). Run the architect agent, or state "
                    f"'Docs not needed: <reason, at least {MIN_REASON} characters>' in the section.")
    if not changed or PLACEHOLDER.match(changed):
        errs.append("'Sections changed:' is missing or empty in the '## Architecture docs' section.")
    if len(errs) == 1:
        return True, [head_msg, f"Docs changed: {', '.join(docs)}", f"Sections changed: {changed}"]
    return False, errs


def main(argv=None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", required=True)
    ap.add_argument("--head", default="")
    ap.add_argument("--files", required=True, help="file with one changed path per line")
    ap.add_argument("--body", required=True, help="file with the PR body")
    a = ap.parse_args(argv)
    files = open(a.files, encoding="utf-8").read().splitlines()
    body = open(a.body, encoding="utf-8").read()
    ok, msgs = evaluate(a.base, a.head, files, body)
    for m in msgs:
        print(m if ok else f"::error::{m}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
