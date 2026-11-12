from scripts.approve_on_comment import (
    decide,
    edit_adds_approval,
    main,
    rejection_reason,
)

WAIT = ["agent:plan-ready", "type:feature"]


def test_owner_approve_on_waiting_issue():
    for body in ("approve", "Approved", "LGTM, go ahead", "approve plan v2\nthanks", "\n  approved."):
        assert decide(body, "admin", WAIT) == "approve", body


def test_maintainer_ok_writer_not():
    assert decide("approve", "maintain", WAIT) == "approve"
    assert decide("approve", "write", WAIT).startswith("skip")
    assert decide("approve", "none", WAIT).startswith("skip")


def test_not_an_approval():
    for body in ("I approve of the idea but change step 2", "do not approve", "approve?", "approve but wait for IT",
                 "not approved", "looks good", ""):
        assert decide(body, "admin", WAIT).startswith("skip"), body


def test_needs_waiting_label_and_not_already_approved():
    assert decide("approve", "admin", ["type:feature"]).startswith("skip")
    assert decide("approve", "admin", ["agent:proposed"]) == "approve"
    assert decide("approve", "admin", ["agent:plan-ready", "agent:approved"]) == "skip: already approved"


def test_pr_and_bot_comments_ignored():
    assert decide("approve", "admin", WAIT, is_pr=True).startswith("skip")
    assert decide("approve", "admin", WAIT, is_bot=True).startswith("skip")


def test_rejection_reply_only_for_real_attempts_refused_for_permission():
    got = rejection_reason("approve", "write", WAIT, owner="boss")
    assert got == "`approve` needs admin or maintain access; @boss please approve."
    assert "E1250871_PNR" in rejection_reason("approve", "none", WAIT)
    assert rejection_reason("approve", "admin", WAIT) == ""
    for body in ("looks good", "approve?", "do not approve", "approve but hold", ""):
        assert rejection_reason(body, "write", WAIT) == "", body
    assert rejection_reason("approve", "write", ["agent:plan-ready", "agent:approved"]) == ""
    assert rejection_reason("approve", "write", ["type:feature"]) == ""
    assert rejection_reason("approve", "write", WAIT, is_pr=True) == ""
    assert rejection_reason("approve", "write", WAIT, is_bot=True) == ""


def test_edit_adds_approval():
    assert edit_adds_approval("thinking", "approve")
    assert not edit_adds_approval("approve", "approve, thanks")
    assert not edit_adds_approval("thinking", "still thinking")
    assert not edit_adds_approval("approve", "retracted")


def test_main_edit_and_reply_file(tmp_path, capsys):
    body, old, reply = tmp_path / "b.md", tmp_path / "o.md", tmp_path / "r.md"
    body.write_text("approve")
    old.write_text("hmm")
    base = ["--body", str(body), "--labels", ",".join(WAIT)]
    main(base + ["--permission", "admin", "--old-body", str(old)])
    assert capsys.readouterr().out.strip() == "approve"
    old.write_text("approve")
    main(base + ["--permission", "admin", "--old-body", str(old)])
    assert capsys.readouterr().out.startswith("skip: edit")
    main(base + ["--permission", "write", "--reply-file", str(reply), "--owner", "boss"])
    assert capsys.readouterr().out.startswith("skip") and "@boss" in reply.read_text()
