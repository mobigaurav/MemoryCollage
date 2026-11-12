# 0001 - Copilot CLI in GitHub Actions as the agent build runtime

Status: accepted

## Context
The repo wants issue-to-PR automation without storing a personal access token or a third-party model key.

## Decision
`plan-on-issue.yml` and `agent-build.yml` run GitHub Copilot CLI in Actions, authorized with the job token and
`copilot-requests: write`. Agents get no GitHub credentials: the workflow commits, pushes and opens PRs, and
an owner approves CI on bot PRs. Scripts in `scripts/` hold the logic and are unit tested.

## Alternatives considered
- A PAT or model API key stored as a secret: more to rotate and leak.
- Copilot coding agent only: less control over gates, protected paths and retries.
- Fully manual flow: no automation.

## Consequences
- Needs Copilot CLI access for the repository (see [SETUP.md](../SETUP.md)).
- Build runs are limited to what a runner can execute; CI remains the judge.
- Protected paths stop automated edits to workflows, infra and signing files.
