"""Validate agent and skill definitions, the registry and evaluation cases.

  python scripts/validate_agents.py      # exit 1 with a list of problems
"""
import glob
import os
import re
import sys

import yaml

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def frontmatter(path: str) -> dict:
    text = open(path, encoding="utf-8").read()
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m:
        raise ValueError("missing frontmatter")
    return yaml.safe_load(m.group(1)) or {}


def links(path: str) -> list[str]:
    text = open(path, encoding="utf-8").read()
    return [t for t in re.findall(r"\]\(([^)#\s]+)(?:#[^)]*)?\)", text) if not re.match(r"[a-z]+:", t)]


def validate(root: str = ROOT) -> list[str]:
    errs: list[str] = []
    agents = {os.path.basename(p)[: -len(".agent.md")]: p for p in glob.glob(f"{root}/.github/agents/*.agent.md")}
    skills = {os.path.basename(os.path.dirname(p)): p for p in glob.glob(f"{root}/.github/skills/*/SKILL.md")}
    for kind, items, required in (("agent", agents, ("name", "version", "description")),
                                  ("skill", skills, ("name", "description"))):
        for name, path in items.items():
            try:
                fm = frontmatter(path)
            except Exception as e:  # noqa: BLE001
                errs.append(f"{kind} {name}: {e}")
                continue
            for k in required:
                if not fm.get(k):
                    errs.append(f"{kind} {name}: frontmatter '{k}' missing")
            if fm.get("name") and fm["name"] != name:
                errs.append(f"{kind} {name}: frontmatter name '{fm['name']}' does not match file name")
            if len(str(fm.get("description", ""))) < 60:
                errs.append(f"{kind} {name}: description too short to route on")
            if kind == "agent" and "## Changelog" not in open(path, encoding="utf-8").read():
                errs.append(f"agent {name}: Changelog section missing")
    for path in list(agents.values()) + list(skills.values()) + [f"{root}/AGENTS.md"]:
        for t in links(path):
            if not os.path.exists(os.path.normpath(os.path.join(os.path.dirname(path), t))):
                errs.append(f"{os.path.relpath(path, root)}: broken link {t}")
    reg = yaml.safe_load(open(f"{root}/agent-platform/registry/agents.yaml", encoding="utf-8"))
    reg_agents = {a["name"]: a for a in reg.get("agents", [])}
    reg_skills = {s["name"] for s in reg.get("skills", [])}
    for a in sorted(set(agents) ^ set(reg_agents)):
        errs.append(f"registry: agent '{a}' is {'not registered' if a in agents else 'registered but has no file'}")
    for s in sorted(set(skills) ^ reg_skills):
        errs.append(f"registry: skill '{s}' is {'not registered' if s in skills else 'registered but has no file'}")
    for name, a in reg_agents.items():
        if name in agents and str(a.get("version")) != str(frontmatter(agents[name]).get("version")):
            errs.append(f"registry: agent '{name}' version differs from its file")
        for s in a.get("skills") or []:
            if s not in skills:
                errs.append(f"registry: agent '{name}' uses unknown skill '{s}'")
    cases = yaml.safe_load(open(f"{root}/agent-platform/evaluations/cases.yaml", encoding="utf-8")).get("cases", [])
    ids = set()
    for c in cases:
        if c.get("id") in ids:
            errs.append(f"eval: duplicate case id {c.get('id')}")
        ids.add(c.get("id"))
        if c.get("agent") not in agents:
            errs.append(f"eval {c.get('id')}: unknown agent {c.get('agent')}")
        for s in c.get("skills") or []:
            if s not in skills:
                errs.append(f"eval {c.get('id')}: unknown skill {s}")
        if not c.get("expect"):
            errs.append(f"eval {c.get('id')}: no expectations")
    return errs


def main() -> int:
    errs = validate()
    for e in errs:
        print("::error::" + e if os.environ.get("GITHUB_ACTIONS") else "ERROR " + e)
    print(f"agents-check: {'FAILED' if errs else 'ok'} ({len(errs)} problems)")
    return 1 if errs else 0


if __name__ == "__main__":
    sys.exit(main())
