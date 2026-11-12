# Agent platform (control plane)

Defines how agents in this repo are catalogued, governed and evaluated. Runtime files that AI tools
read live in `.github/agents/` and `.github/skills/`; this folder is the source of truth for
*which* agents exist and the rules they run under.

```
agent-platform/
+-- registry/      agents.yaml (agents + skills), repositories.yaml
+-- policies/      guardrails.md (what agents may never do), approvals.md (who approves what)
+-- evaluations/   cases.yaml (routing and behavior cases), README.md (how to run)
```

Rules
1. Every agent and skill file is listed in `registry/agents.yaml`; CI fails otherwise.
2. Agent changes bump `version` and add a Changelog line.
3. New behavior needs at least one evaluation case.
