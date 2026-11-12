"""Turn an owner's "approve" comment on an issue into the agent:approved label (issue #31).

Run by .github/workflows/approve-on-comment.yml. Decision logic is pure and unit-tested; the workflow
does the GitHub calls with the job token.

  python scripts/approve_on_comment.py --body comment.md --permission admin --labels "agent:plan-ready,type:feature"
  -> prints 'approve' or 'skip: <reason>'; exit code is always 0
  --old-body old.md   the comment is an edit: approve only if the edit added the leading approve word
  --reply-file r.md   write the rejection reply (permission refusals only) for the workflow to post
"""
from __future__ import annotations

import argparse
import re
import sys

APPROVAL = re.compile(r"^\s*(approve|approved|lgtm)\b(?!\s*\?)", re.I)
NEGATION = re.compile(r"\b(not|don't|do not|hold|wait|reject|rejected)\b", re.I)
ALLOWED_PERMISSIONS = {"admin", "maintain"}
WAITING_LABELS = {"agent:plan-ready", "agent:proposed"}
DEFAULT_OWNER = "E1250871_PNR"


def rejection_reply(command: str, needs: str, owner: str = "") -> str:
    """Short comment for a command refused for permission; @-mentions the owner."""
    owner = (owner or DEFAULT_OWNER).lstrip("@")
    return f"`{command}` needs {needs}; @{owner} please {command}."


def edit_adds_approval(old_body: str, new_body: str) -> bool:
    """True when an edit adds a leading approve word that the old text did not have."""
    first = lambda t: next((ln for ln in (t or "").splitlines() if ln.strip()), "")  # noqa: E731
    return bool(APPROVAL.match(first(new_body))) and not APPROVAL.match(first(old_body))


def rejection_reason(body: str, permission: str, labels: list[str], is_pr: bool = False,
                     is_bot: bool = False, owner: str = "") -> str:
    """Reply text only for a real approve attempt on a waiting issue refused for permission, else ''."""
    if is_pr or is_bot or permission in ALLOWED_PERMISSIONS:
        return ""
    first = next((ln for ln in (body or "").splitlines() if ln.strip()), "")
    if not APPROVAL.match(first) or NEGATION.search(first):
        return ""
    labels = {x.strip() for x in labels if x.strip()}
    if "agent:approved" in labels or not labels & WAITING_LABELS:
        return ""
    return rejection_reply("approve", "admin or maintain access", owner)


def decide(body: str, permission: str, labels: list[str], is_pr: bool = False, is_bot: bool = False) -> str:
    """'approve' or 'skip: <reason>'."""
    first = next((ln for ln in (body or "").splitlines() if ln.strip()), "")
    if is_pr:
        return "skip: comment is on a pull request"
    if is_bot:
        return "skip: comment is from a bot"
    if not APPROVAL.match(first):
        return "skip: first line does not start with approve / approved / lgtm"
    if NEGATION.search(first):
        return "skip: first line also contains a negation or hold word"
    if permission not in ALLOWED_PERMISSIONS:
        return f"skip: commenter permission is '{permission}', needs admin or maintain"
    labels = {x.strip() for x in labels if x.strip()}
    if "agent:approved" in labels:
        return "skip: already approved"
    if not labels & WAITING_LABELS:
        return "skip: issue is not waiting for plan approval (needs agent:plan-ready or agent:proposed)"
    return "approve"


def main(argv=None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--body", required=True, help="file with the comment body")
    ap.add_argument("--permission", default="none")
    ap.add_argument("--labels", default="")
    ap.add_argument("--is-pr", action="store_true")
    ap.add_argument("--is-bot", action="store_true")
    ap.add_argument("--old-body", help="file with the comment body before an edit")
    ap.add_argument("--reply-file", help="write the rejection reply here when there is one")
    ap.add_argument("--owner", default="")
    a = ap.parse_args(argv)
    body = open(a.body, encoding="utf-8").read()
    labels = a.labels.split(",")
    if a.old_body is not None:
        old = open(a.old_body, encoding="utf-8").read()
        if not edit_adds_approval(old, body):
            print("skip: edit did not add an approve command")
            return 0
    if a.reply_file:
        reply = rejection_reason(body, a.permission, labels, a.is_pr, a.is_bot, a.owner)
        if reply:
            with open(a.reply_file, "w", encoding="utf-8") as fh:
                fh.write(reply)
    print(decide(body, a.permission, labels, a.is_pr, a.is_bot))
    return 0


if __name__ == "__main__":
    sys.exit(main())
