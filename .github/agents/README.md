# Agents

Tool-neutral agent definitions. GitHub Copilot Chat lists them in the agent picker (`@<name>`);
other runtimes load them by path. Start with `delivery-orchestrator` unless you
need one specialist. Registry: [agent-platform/registry/agents.yaml](../../agent-platform/registry/agents.yaml).

| Agent | Name | Purpose |
|---|---|---|
| [`delivery-orchestrator`](delivery-orchestrator.agent.md) | Delivery Orchestrator | Default entry point. Prompt or bug report to issue, approved plan, implementation, tests, PR into dev, release to main. |
| [`architect`](architect.agent.md) | Architect | Keeps docs/SYSTEM_DESIGN.md and other docs accurate; writes ADRs; fills the PR's Architecture docs section. |
| [`planner`](planner.agent.md) | Planner | Turns an issue into an implementation plan and stops for approval. |
| [`developer`](developer.agent.md) | Developer | Implements an approved plan in the Flutter app, API or web site. |
| [`unit-test-author`](unit-test-author.agent.md) | Unit Test Author | Unit tests only (Flutter, API, scripts). |
| [`integration-test-author`](integration-test-author.agent.md) | Integration Test Author | Integration tests only (API with TestClient, widget flows, scripts). |
| [`reviewer`](reviewer.agent.md) | Reviewer | Read-only adversarial review of a PR or diff. |
| [`pr-release-manager`](pr-release-manager.agent.md) | PR and Release Manager | Branches, commits, PRs to dev, release PR dev -> main. |
| [`cicd-ops`](cicd-ops.agent.md) | CI/CD and Ops | Failed runs, expired tokens, deploy problems, workflow changes. |

## Examples
```
@delivery-orchestrator Add a "share album" button to the album screen
@delivery-orchestrator Fix #12
@planner plan #7
@unit-test-author cover my diff
@reviewer review PR #9
@cicd-ops why did the web deploy fail?
```

## Changing an agent
Bump `version`, add a Changelog line, update the registry, and run `make agents-check`. Agent and
skill changes are code: they go through an issue and PR like everything else.
