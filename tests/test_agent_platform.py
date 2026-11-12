import os
import shutil

from scripts import validate_agents

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def test_repo_agents_valid():
    assert validate_agents.validate(ROOT) == []


def _copy(tmp_path):
    for p in (".github/agents", ".github/skills", "agent-platform", "docs"):
        shutil.copytree(os.path.join(ROOT, p), tmp_path / p)
    shutil.copy(os.path.join(ROOT, "AGENTS.md"), tmp_path / "AGENTS.md")
    for p in ("README.md", "Makefile"):
        shutil.copy(os.path.join(ROOT, p), tmp_path / p)
    return tmp_path


def test_detects_unregistered_agent_and_bad_frontmatter(tmp_path):
    root = _copy(tmp_path)
    (root / ".github/agents/rogue.agent.md").write_text("---\nname: rogue\n---\nno changelog\n")
    errs = validate_agents.validate(str(root))
    assert any("rogue" in e and "not registered" in e for e in errs)
    assert any("rogue" in e and "version" in e for e in errs)


def test_detects_broken_skill_link(tmp_path):
    root = _copy(tmp_path)
    p = root / ".github/agents/developer.agent.md"
    p.write_text(p.read_text() + "\nSee [missing](../skills/nope/SKILL.md)\n")
    assert any("broken link" in e for e in validate_agents.validate(str(root)))
