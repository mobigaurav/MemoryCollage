from scripts.check_docs import evaluate, section

GOOD = """## Summary
x

## Architecture docs
Sections changed: SYSTEM_DESIGN 4.7, 6.3; ADR 0001

## Validation
"""


def test_no_trigger_files_passes():
    ok, _ = evaluate("dev", "DEV_9", ["tests/test_x.py", "apps/web/src/app/globals.css"], "")
    assert ok


def test_trigger_without_docs_fails():
    ok, msgs = evaluate("dev", "DEV_9", ["services/api/mb_api/main.py"], "")
    assert not ok
    assert any("Architecture docs" in m for m in msgs)
    assert any("No docs changed" in m for m in msgs)


def test_trigger_with_docs_and_sections_passes():
    ok, _ = evaluate("dev", "DEV_9", ["services/api/mb_api/main.py", "docs/SYSTEM_DESIGN.md"], GOOD)
    assert ok


def test_docs_changed_but_section_missing_fails():
    ok, msgs = evaluate("dev", "DEV_9", ["infra/lite/template.yaml", "docs/SYSTEM_DESIGN.md"], "## Summary\nx\n")
    assert not ok and any("Sections changed" in m for m in msgs)


def test_template_placeholder_does_not_count():
    body = "## Architecture docs\n<!-- architect fills this -->\nSections changed: <list>\nDocs not needed: <reason>\n"
    ok, _ = evaluate("dev", "DEV_9", [".github/workflows/ci.yml", "docs/a.md"], body)
    assert not ok


def test_docs_not_needed_with_reason_passes():
    body = "## Architecture docs\nDocs not needed: internal refactor of a helper, no behavior change\n"
    ok, msgs = evaluate("dev", "DEV_9", ["services/api/mb_api/store.py"], body)
    assert ok and any("Docs not needed" in m for m in msgs)


def test_docs_not_needed_short_reason_fails():
    ok, _ = evaluate("dev", "DEV_9", ["services/api/mb_api/store.py"], "## Architecture docs\nDocs not needed: n/a\n")
    assert not ok


def test_release_and_dependabot_pass():
    assert evaluate("main", "dev", ["services/api/mb_api/x.py"], "")[0]
    assert evaluate("dev", "dependabot/pip/requests-2", ["scripts/x.py"], "")[0]


def test_section_stops_at_next_heading():
    s = section("## Architecture docs\nSections changed: 4.7\n## Tests\nSections changed: nope\n")
    assert "4.7" in s and "nope" not in s
