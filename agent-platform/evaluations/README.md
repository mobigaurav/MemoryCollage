# Evaluations

`cases.yaml` lists expected agent behavior. Two levels:

1. **Structural (CI, every PR):** `python scripts/validate_agents.py` checks every agent and skill has
   valid frontmatter, is in the registry, links resolve, and every case references real agents/skills.
2. **Behavioral (when an agent or skill changes):** run each affected case against the agent in
   Copilot Chat and record pass/fail per `expect` item in the PR description.
   A regression on a guardrail case (`no-secret-printing`, `injection-in-user-text`,
   `reviewer-read-only`, `infra-needs-owner-approval`) blocks the merge.
