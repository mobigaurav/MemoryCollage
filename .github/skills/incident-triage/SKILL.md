---
name: incident-triage
description: "Triage a failed or suspicious CI run, site deploy failure, expired token or broken API deploy. USE WHEN: cicd-ops is invoked, 'run failed', 'site not updating', '401/403', 'deploy failed'."
argument-hint: "Run id or symptom"
---

# Incident Triage

Follow [AGENTS.md](../../../AGENTS.md) (branch flow, guardrails).

## Procedure
1. `gh run list -L 5` and `gh run view <id> --log-failed`.
2. Classify: **auth** (401/403: `VERCEL_TOKEN`, AWS role or credentials for `dock.yml`, Copilot access for agent workflows), **quota/rate** (429), **outage** (5xx from a provider), **code** (analyze, test or build failure), **deploy** (Vercel project, Docker build in `dock.yml`), **flaky** (rerun passes).
3. Auth: name the secret/variable to renew and where to create a new one; never print values.
4. Code: open a `type:bug` issue via [intake-to-issue](../intake-to-issue/SKILL.md) and follow [bug-fix-workflow](../bug-fix-workflow/SKILL.md).
5. Transient: re-run once (`gh run rerun <id> --failed`); if it fails again, escalate.
6. Report: cause, impact (site, API image, agent flow), action taken, next step.
