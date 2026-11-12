"""Release to main and close-out (issue #35, Phase 4).

  ship      ship-on-comment.yml: an owner or maintainer comments `ship` on the open release PR
            (dev -> main, label `release`). Waits for REQUIRED_CHECKS on the PR head, merges with a merge
            commit, then dispatches web.yml on main (a merge made with the job token starts no push
            workflows, and the site deploys from web.yml).
  closeout  release-closeout.yml, after web.yml succeeded on main: every open issue
            that a merged PR into dev closes ("Closes/Fixes/Resolves #N" in the PR body) and whose merge
            commit is now on main gets a "Released" comment, the `released` label, and is closed as
            completed. Branch names alone never close an issue (DEV_35 style phase branches use "Refs").
"""
from __future__ import annotations

import os
import re
import subprocess
import sys
import time

from scripts.agent_build import CHECKS_TEXT, OWNER_PERMS, REQUIRED_CHECKS, GitHub, checks_state
from scripts.approve_on_comment import rejection_reply

CLOSES = re.compile(r"\b(?:close[sd]?|fix(?:e[sd])?|resolve[sd]?)\s+#(\d+)\b", re.I)
SHIP = re.compile(r"^\s*/?ship\b", re.I)
RELEASED = "released"
CLEAR_LABELS = ("agent:in-progress", "agent:awaiting-ci-approval", "agent:needs-human", "agent:plan-ready")


# ---------------------------------------------------------------- pure helpers
def wants_ship(body: str, perm: str, pr: dict) -> tuple[bool, str]:
    if not SHIP.match((body or "").splitlines()[0] if body else ""):
        return False, "skip: not a ship comment"
    if perm not in OWNER_PERMS:
        return False, f"skip: needs admin or maintain (has {perm})"
    labels = {lb["name"] for lb in pr.get("labels") or []}
    if pr.get("state") != "open" or "release" not in labels:
        return False, "skip: not an open release PR"
    if (pr.get("base") or {}).get("ref") != "main" or (pr.get("head") or {}).get("ref") != "dev":
        return False, "skip: release PRs go dev -> main"
    return True, "ship"


def closed_by(prs: list[dict]) -> dict[int, dict]:
    """{issue number: merged PR} from closing keywords in merged PR bodies (newest PR wins)."""
    out: dict[int, dict] = {}
    for pr in sorted(prs, key=lambda p: p.get("number", 0)):
        if not pr.get("merged_at") or not pr.get("merge_commit_sha"):
            continue
        for n in CLOSES.findall(pr.get("body") or ""):
            out[int(n)] = pr
    return out


def released_comment(pr: dict, deploy_url: str, sha: str) -> str:
    return (f"Released: PR #{pr['number']} is on main ({sha[:7]}) and the site deploy workflow finished in "
            f"[this run]({deploy_url}). Closing as completed.")


# ---------------------------------------------------------------- commands
def is_on_main(sha: str) -> bool:
    return subprocess.run(["git", "merge-base", "--is-ancestor", sha, "origin/main"],
                          capture_output=True).returncode == 0


def cmd_closeout(gh: GitHub, env: dict, on_main=is_on_main) -> str:
    prs = gh.req("GET", "pulls", params={"base": "dev", "state": "closed", "per_page": 100,
                                         "sort": "updated", "direction": "desc"})
    done = []
    for n, pr in closed_by(prs).items():
        issue = gh.issue(n)
        if issue.get("state") != "open" or issue.get("pull_request") is not None:
            continue
        if not on_main(pr["merge_commit_sha"]):
            continue
        gh.comment(n, released_comment(pr, env.get("RUN_URL", ""), env.get("GITHUB_SHA", "")))
        gh.add_labels(n, [RELEASED])
        names = {lb["name"] for lb in issue.get("labels") or []}
        for lb in CLEAR_LABELS:
            if lb in names:
                gh.remove_label(n, lb)
        gh.req("PATCH", f"issues/{n}", json={"state": "closed", "state_reason": "completed"})
        done.append(n)
    return "closed: " + (", ".join(f"#{n}" for n in done) or "none")


def cmd_ship(gh: GitHub, env: dict, sleep=time.sleep) -> str:
    num, login = int(env["PR"]), env.get("LOGIN", "")
    pr = gh.req("GET", f"pulls/{num}")
    perm = gh.permission(login)
    ok, why = wants_ship(env.get("BODY", ""), perm, pr)
    if not ok:
        if perm not in OWNER_PERMS and SHIP.match((env.get("BODY") or "").splitlines()[0] if env.get("BODY") else ""):
            gh.comment(num, rejection_reply("ship", "admin or maintain access", env.get("OWNER_LOGIN", "")))
        return why
    run_url = env.get("RUN_URL", "")
    gh.comment(num, f"Shipping for @{login} ([run]({run_url})): waiting for {CHECKS_TEXT}. "
                    "If GitHub shows \"Approve workflows to run\" on this PR, approve them first.")
    deadline = time.time() + int(env.get("SHIP_TIMEOUT_S") or 1800)
    while True:
        pr = gh.req("GET", f"pulls/{num}")
        if pr.get("state") != "open":
            return "skip: PR no longer open"
        state, runs = checks_state(gh.check_runs(pr["head"]["sha"]))
        if state != "pending" or time.time() > deadline:
            break
        sleep(30)
    if state != "success":
        bad = [n for n in REQUIRED_CHECKS if (runs.get(n) or {}).get("conclusion") != "success"]
        gh.comment(num, f"Not shipped ([run]({run_url})): {', '.join(bad)} "
                        f"{'did not pass' if state == 'failure' else 'did not finish in time'}. Comment `ship` again "
                        "after fixing or approving the checks.")
        return f"not shipped: {state}"
    gh.req("PUT", f"pulls/{num}/merge", json={"merge_method": "merge", "sha": pr["head"]["sha"],
                                              "commit_title": f"Merge pull request #{num} from dev (ship by @{login})"})
    gh.dispatch("web.yml", "main", {})
    gh.comment(num, f"Shipped: merged into main for @{login}. The site deploy (web.yml) started; released issues "
                    "are closed when it succeeds.")
    return f"shipped #{num}"


def main(argv=None) -> int:
    argv = argv or sys.argv[1:]
    env = dict(os.environ)
    gh = GitHub(env["GITHUB_TOKEN"], env["GITHUB_REPOSITORY"])
    print({"ship": cmd_ship, "closeout": cmd_closeout}[argv[0]](gh, env))
    return 0


if __name__ == "__main__":
    sys.exit(main())
