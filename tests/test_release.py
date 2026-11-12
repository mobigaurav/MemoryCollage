import os

import yaml

from scripts import release as r
from scripts.agent_build import REQUIRED_CHECKS


def rpr(state="open", labels=("release",), base="main", head="dev", sha="abc"):
    return {"number": 49, "state": state, "labels": [{"name": x} for x in labels], "base": {"ref": base},
            "head": {"ref": head, "sha": sha}}


def test_wants_ship():
    assert r.wants_ship("ship", "admin", rpr())[0]
    assert r.wants_ship("/ship it\nthanks", "maintain", rpr())[0]
    assert "not a ship" in r.wants_ship("shipping later", "admin", rpr())[1]
    assert "needs admin" in r.wants_ship("ship", "write", rpr())[1]
    assert "release PR" in r.wants_ship("ship", "admin", rpr(labels=()))[1]
    assert "dev -> main" in r.wants_ship("ship", "admin", rpr(head="DEV_9"))[1]
    assert not r.wants_ship("", "admin", rpr())[0]


def mpr(n, body, merged=True, sha="m1"):
    return {"number": n, "body": body, "merged_at": "2026-10-27" if merged else None,
            "merge_commit_sha": sha if merged else None}


def test_closed_by_uses_keywords_only():
    prs = [mpr(46, "Closes #45"), mpr(43, "Refs #35 (stays open)"), mpr(50, "Fixes #7 and resolves #8"),
           mpr(51, "Closes #9", merged=False)]
    assert sorted(r.closed_by(prs)) == [7, 8, 45]


class GH:
    def __init__(self, issues, prs, runs=None):
        self.issues, self.prs, self.runs = issues, prs, runs or []
        self.posted, self.added, self.removed, self.reqs, self.dispatched = [], [], [], [], []
        self.pr_state = rpr()
        self.perm = "admin"

    def req(self, method, path, ok=None, **kw):
        self.reqs.append((method, path, kw.get("json")))
        if path == "pulls":
            return self.prs
        if path.startswith("pulls/") and method == "GET":
            return self.pr_state
        return {}

    def issue(self, n):
        return self.issues[n]

    def comment(self, n, body):
        self.posted.append((n, body))

    def add_labels(self, n, labels):
        self.added += labels

    def remove_label(self, n, label):
        self.removed.append(label)

    def permission(self, login):
        return self.perm

    def check_runs(self, sha):
        return self.runs

    def dispatch(self, wf, ref, inputs):
        self.dispatched.append((wf, ref, inputs))


def iss(state="open", labels=("agent:approved", "agent:in-progress")):
    return {"state": state, "labels": [{"name": x} for x in labels]}


def test_closeout_closes_only_released_open_issues():
    gh = GH({45: iss(), 7: iss(), 8: iss(state="closed")},
            [mpr(46, "Closes #45", sha="onmain"), mpr(50, "Fixes #7", sha="devonly"), mpr(52, "Closes #8")])
    out = r.cmd_closeout(gh, {"RUN_URL": "u", "GITHUB_SHA": "1234567890"}, on_main=lambda s: s == "onmain")
    assert out == "closed: #45"
    assert gh.posted[0][0] == 45 and "PR #46" in gh.posted[0][1] and "1234567" in gh.posted[0][1]
    assert ("PATCH", "issues/45", {"state": "closed", "state_reason": "completed"}) in gh.reqs
    assert "released" in gh.added and "agent:in-progress" in gh.removed


def cr(name, conclusion="success"):
    return {"name": name, "status": "completed", "conclusion": conclusion, "id": 1}


def test_ship_merges_and_deploys():
    gh = GH({}, [], runs=[cr(n) for n in REQUIRED_CHECKS])
    assert r.cmd_ship(gh, {"PR": "49", "LOGIN": "owner", "BODY": "ship"}, sleep=lambda s: None) == "shipped #49"
    merge = [x for x in gh.reqs if x[0] == "PUT"][0]
    assert merge[1] == "pulls/49/merge" and merge[2]["merge_method"] == "merge"
    assert gh.dispatched == [("web.yml", "main", {})]


def test_ship_refuses_failed_checks():
    gh = GH({}, [], runs=[cr(n) for n in REQUIRED_CHECKS[:-1]] + [cr("plan-gate", "failure")])
    assert r.cmd_ship(gh, {"PR": "49", "LOGIN": "o", "BODY": "ship"}, sleep=lambda s: None) == "not shipped: failure"
    assert not [x for x in gh.reqs if x[0] == "PUT"] and "plan-gate" in gh.posted[-1][1]


def test_ship_times_out_when_checks_held():
    gh = GH({}, [], runs=[])
    env = {"PR": "49", "LOGIN": "o", "BODY": "ship", "SHIP_TIMEOUT_S": "0"}
    assert r.cmd_ship(gh, env, sleep=lambda s: None) == "not shipped: pending"


def _wf(name):
    return yaml.safe_load(open(os.path.join(os.path.dirname(__file__), "..", ".github", "workflows", name)))


def test_closeout_workflow_runs_after_site_deploy_on_main():
    wf = _wf("release-closeout.yml")
    trig = wf.get("on") or wf.get(True)
    assert trig["workflow_run"]["workflows"] == ["web"] and trig["workflow_run"]["types"] == ["completed"]
    job = wf["jobs"]["closeout"]
    assert "success" in job["if"] and "main" in job["if"]
    assert job["permissions"]["issues"] == "write" and "contents" in job["permissions"]


def test_ship_workflow_is_pr_only():
    wf = _wf("ship-on-comment.yml")
    assert "pull_request != null" in wf["jobs"]["ship"]["if"] and "release" in wf["jobs"]["ship"]["if"]


def test_wants_ship_ignores_approve_and_dev_prs():
    assert not r.wants_ship("approve", "admin", rpr())[0]
    assert not r.wants_ship("ship", "admin", rpr(labels=(), head="DEV_9", base="dev"))[0]


def test_ship_rejection_replies_only_for_real_ship_comments():
    gh = GH({}, [])
    gh.perm = "write"
    out = r.cmd_ship(gh, {"PR": "49", "LOGIN": "pm", "BODY": "ship", "OWNER_LOGIN": "boss"}, sleep=lambda s: None)
    assert out.startswith("skip") and gh.posted == [(49, "`ship` needs admin or maintain access; @boss please ship.")]
    gh = GH({}, [])
    gh.perm = "write"
    r.cmd_ship(gh, {"PR": "49", "LOGIN": "pm", "BODY": "thanks"}, sleep=lambda s: None)
    assert not gh.posted
