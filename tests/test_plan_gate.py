import json

from scripts.plan_gate import evaluate, linked_issues, main

LABELS = {35: ["type:feature", "agent:approved"], 36: ["agent:plan-ready"], 37: ["agent:approved"]}


def look(n):
    return LABELS.get(n)


def test_linked_from_branch_and_body():
    assert linked_issues("DEV_35", "Closes #37\nfixes #35") == [35, 37]
    assert linked_issues("DEV_35-footer", "") == [35]
    assert linked_issues("feature/x", "Resolves: #36") == [36]
    assert linked_issues("DEV_x", "see #12") == []


def test_comment_refs_ignored():
    assert linked_issues("feature/x", "<!-- Closes #36 -->") == []


def test_approved_branch_passes():
    ok, msgs = evaluate("dev", "DEV_35", "", look)
    assert ok and "plan approved" in msgs[0]


def test_unapproved_issue_fails():
    ok, msgs = evaluate("dev", "DEV_36", "", look)
    assert not ok and "approve" in msgs[0]


def test_every_linked_issue_must_be_approved():
    assert evaluate("dev", "DEV_35", "Closes #37", look)[0]
    assert not evaluate("dev", "DEV_35", "Closes #36", look)[0]


def test_no_link_or_missing_issue_fails():
    assert not evaluate("dev", "feature/x", "", look)[0]
    ok, msgs = evaluate("dev", "DEV_999", "", look)
    assert not ok and "not found" in msgs[0]


def test_exemptions():
    assert evaluate("main", "dev", "", look)[0]
    assert evaluate("main", "hotfix/x", "", look)[0]
    assert evaluate("dev", "main", "", look)[0]
    assert evaluate("dev", "dependabot/pip/x", "", look)[0]


def test_cli_offline(tmp_path):
    body = tmp_path / "b.md"
    body.write_text("Closes #36\n")
    lab = tmp_path / "l.json"
    lab.write_text(json.dumps({str(k): v for k, v in LABELS.items()}))
    assert main(["--base", "dev", "--head", "DEV_35", "--body", str(body), "--labels-json", str(lab)]) == 1
    body.write_text("")
    assert main(["--base", "dev", "--head", "DEV_35", "--body", str(body), "--labels-json", str(lab)]) == 0
