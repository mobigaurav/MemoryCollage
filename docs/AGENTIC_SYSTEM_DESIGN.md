# Agentic development - system design

Design of the agent platform in this repo: components, state machine, enforcement and failure handling.
Quick guide: [AGENTIC_DEVELOPMENT.md](AGENTIC_DEVELOPMENT.md). Setup: [SETUP.md](SETUP.md).
Product architecture: [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md).

## 1. Summary
```
 +-------------+  issue   +----------------+  plan   +----------+  approve  +----------------+
 | person or   |--------->| GitHub Issue   |-------->| planner  |---------->| agent-build.yml|
 | chat        |          | agent:proposed |  (CLI)  | comment  |  comment  | Copilot CLI    |
 +-------------+          +----------------+         +----------+           +-------+--------+
                                                                                     | patch
 +-----------------+  checks pass   +------------------+  open PR   +---------------v--------+
 | agent-merge.yml |<---------------| ci + docs-check  |<-----------| DEV_<N> PR into dev    |
 | squash to dev   |   owner clicks | (API, Web,       |            +------------------------+
 +--------+--------+   "Approve     |  Flutter, agents |
          |            workflows"   |  -check, branch- |
          v                         |  policy, plan-   |
 +-----------------+  `ship`        |  gate, docs)     |
 | release PR      |--------------->+------------------+
 | dev -> main     |  ship-on-comment.yml merges, dispatches web.yml; release-closeout.yml closes issues
 +-----------------+
```

## 2. Actors
- **Owner / maintainer:** approves plans (`approve`), clicks "Approve workflows to run", merges or `ship`s releases, does store builds.
- **Agents:** Markdown definitions in `.github/agents`, run by Copilot (Chat, CLI in Actions).
- **Workflows:** the only components with GitHub write access; scripts in `scripts/` hold the logic and are unit tested.

## 3. Control plane and enforcement
| Rule | Enforced by |
|---|---|
| Agent and skill files valid, registered, links resolve | `scripts/validate_agents.py` (CI job `agents-check`) |
| Issue approved before merge | `plan-gate` (`scripts/plan_gate.py`, required) |
| Architecture docs updated | `docs-check` (`scripts/check_docs.py`, required) |
| Branch arrows | `branch-policy` job in `ci.yml` (required) |
| No protected path changed by an automated build | `scripts/protected_paths.py` in `agent-build.yml` |
| No secrets in agent runs | token env hidden from the CLI, shell `git push`/`gh`/`curl` denied, docs sites allow-listed |
| Existing app, API, web checks | `ci.yml` jobs API, Web, Flutter (required) |

Instruction-only rules (agent files, guardrails) still apply but are not machine enforced; the table lists what is.

## 4. Issue state machine
```
 (new issue) --> agent:proposed --plan--> agent:plan-ready --approve--> agent:approved
      replan resets approval  ^                                              |
                              +----------------------------------------------v
 agent:in-progress --PR opened--> agent:awaiting-ci-approval --checks pass--> merged into dev
        |                                  | checks fail twice
        |                                  v
        |                          agent:needs-human
        +--> released (closed) after the release PR deploys
```

## 5. Workflows
| Workflow | Trigger | Job |
|---|---|---|
| `ci.yml` | PR, push to dev/main | API, Web, Flutter, agents-check, branch-policy |
| `docs-check.yml` | PR, dispatch | docs-check, plan-gate |
| `plan-on-issue.yml` | issue opened or `replan` comment | planner writes the plan comment |
| `approve-on-comment.yml` | `approve` comment | adds `agent:approved`, dispatches the build |
| `agent-build.yml` | dispatch | Copilot builds, workflow opens the PR |
| `agent-merge.yml` | `ci` or `Docs check` finished | squash-merge into dev, retry or hand to a human |
| `ship-on-comment.yml` | `ship` on release PR | merge dev -> main, dispatch `web.yml` |
| `release-closeout.yml` | `web` finished on main | close released issues |
| `web.yml`, `dock.yml` | existing | site deploy; claim comment |

## 6. Trust boundaries
- Issue and comment text reach the agent as quoted data. Agents run without GitHub credentials; the
  workflow, not the agent, commits, pushes and opens PRs.
- Copilot is authorized with the job token (`copilot-requests: write`); no personal access token is stored.
- Workflows that act on comments check the commenter's permission (admin or maintain) first.

## 7. Failure handling
- Build fails checks: the failure is passed to a retry (up to two), then `agent:needs-human`.
- Copilot unavailable or `AGENT_BUILD_ENABLED=false`: the flow stops with a comment; work continues by hand.
- Protected path touched: the build stops and says which path.
- Stuck CI on a bot PR: the owner clicks "Approve workflows to run".

## 8. Extending
Add an agent: file in `.github/agents`, entry in `registry/agents.yaml`, at least one case in
`evaluations/cases.yaml`, `make agents-check`. Add a skill the same way. A new protected path goes in
`scripts/protected_paths.py` with a test. A new doc trigger goes in `scripts/check_docs.py`.

## 9. Known gaps
- No auto-approve-by-comment for `dev` PRs and no automatic release-PR sync (the source platform has them; not ported).
- Flutter, API and web checks run in `ci.yml` only; the agent build runs them best effort on a runner.
- Store builds and AWS deploys are manual by design.
