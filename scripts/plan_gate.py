"""Plan gate for pull requests (issue #35).

A PR into dev may merge only when every issue it is linked to carries the `agent:approved` label,
so no code reaches dev without an owner-approved implementation plan. Linked issues come from the
branch name `DEV_<N>` and from closing keywords in the PR body (`Closes #N`, `Fixes #N`,
`Resolves #N`). PRs into main (release, hotfix), main back-merges and Dependabot pass.

  python scripts/plan_gate.py --repo owner/name --base dev --head DEV_35 --body body.md
  python scripts/plan_gate.py ... --labels-json labels.json    # offline: {"35": ["agent:approved"]}
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from typing import Callable

APPROVED = "agent:approved"
BRANCH = re.compile(r"^DEV_(\d+)(?:\D|$)")
CLOSING = re.compile(r"\b(?:close[sd]?|fix(?:e[sd])?|resolve[sd]?)\s*:?\s+#(\d+)\b", re.I)


def linked_issues(head: str, body: str) -> list[int]:
    """Issue numbers from the branch name first, then closing keywords in the body (comments removed)."""
    body = re.sub(r"<!--.*?-->", "", body or "", flags=re.S)
    found: list[int] = []
    m = BRANCH.match(head or "")
    if m:
        found.append(int(m.group(1)))
    for n in CLOSING.findall(body):
        if int(n) not in found:
            found.append(int(n))
    return found


def evaluate(base: str, head: str, body: str,
             labels_of: Callable[[int], list[str] | None]) -> tuple[bool, list[str]]:
    """Return (ok, messages). labels_of(n) returns the issue's label names, or None if not found."""
    if base != "dev":
        return True, [f"PR into {base}: plans were checked when the changes merged into dev."]
    if head.startswith("dependabot/"):
        return True, ["Dependabot PR: plan gate skipped."]
    if head == "main":
        return True, ["Back-merge from main: plan gate skipped."]
    issues = linked_issues(head, body)
    if not issues:
        return False, ["No linked issue. Name the branch DEV_<issue> or add 'Closes #<issue>' to the PR body."]
    ok, msgs = True, []
    for n in issues:
        labels = labels_of(n)
        if labels is None:
            ok = False
            msgs.append(f"#{n}: issue not found.")
        elif APPROVED in labels:
            msgs.append(f"#{n}: plan approved ({APPROVED}).")
        else:
            ok = False
            msgs.append(f"#{n}: no '{APPROVED}' label. The owner approves the plan by commenting "
                        "'approve' on the issue; then re-run this check.")
    return ok, msgs


def gh_labels(repo: str) -> Callable[[int], list[str] | None]:
    def lookup(n: int) -> list[str] | None:
        r = subprocess.run(["gh", "api", f"repos/{repo}/issues/{n}", "--jq", "[.labels[].name]"],
                           capture_output=True, text=True)
        return json.loads(r.stdout) if r.returncode == 0 and r.stdout.strip() else None
    return lookup


def main(argv=None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", required=True)
    ap.add_argument("--head", default="")
    ap.add_argument("--body", required=True, help="file with the PR body")
    ap.add_argument("--repo", default="")
    ap.add_argument("--labels-json", default="", help="offline label map for testing")
    a = ap.parse_args(argv)
    body = open(a.body, encoding="utf-8").read()
    if a.labels_json:
        table = json.load(open(a.labels_json, encoding="utf-8"))
        lookup = lambda n: table.get(str(n))  # noqa: E731
    else:
        lookup = gh_labels(a.repo)
    ok, msgs = evaluate(a.base, a.head, body, lookup)
    for m in msgs:
        print(m if ok else f"::error::{m}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
