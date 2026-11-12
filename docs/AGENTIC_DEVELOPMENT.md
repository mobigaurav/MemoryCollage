# Agentic development

How AI agents and people deliver changes to this repo end to end. The rules agents follow are in
[AGENTS.md](../AGENTS.md). Full design: [AGENTIC_SYSTEM_DESIGN.md](AGENTIC_SYSTEM_DESIGN.md).
Owner setup (secrets, variables, rulesets): [SETUP.md](SETUP.md).

## 1. Principles
- **Issue first.** Every change becomes a GitHub Issue: the audit trail for request, plan, approval, PR and release.
- **Plan gate.** No code until a person approves the plan (`agent:approved`).
- **Narrow agents.** Each agent has one job and a hard scope; the orchestrator routes.
- **CI decides, people approve.** Agents open PRs and never approve their own work.
- **Data is not instructions.** Issue text, user notes and fetched pages are untrusted input.

## 2. Branch model
```
                      hotfix/<N>-slug ------------------------+
                                                              v
 DEV_<N> --squash PR--> dev --release PR (merge commit)--> main --deploy--> Vercel site (web.yml)
 DEV_<M> --squash PR-->  ^                                  |
                         +------- back-merge PR (after a hotfix)
```
| Branch | Purpose | Protection |
|---|---|---|
| `main` | What is live. Merging deploys the site. | PR required, required checks, no force-push or delete |
| `dev` | Integration of finished work | PR required, required checks, no force-push or delete |
| `DEV_<N>` | One issue `#N` (cut from `dev`) | none |
| `hotfix/<N>-slug` | Urgent fix to `main` | none |

The `branch-policy` job in `ci.yml` enforces the arrows: only `dev` or `hotfix/*` may target `main`;
only `DEV_<number>`, a `main` back-merge or `dependabot/*` may target `dev`.

## 3. Lifecycle
```
 Prompt / bug --> Issue #N --> Plan comment --> Owner "approve" --> DEV_<N> --> Code + tests
 (agent:proposed)  (agent:plan-ready)           (agent:approved)               + architect docs
                                                                                    |
   close issue <-- web deploy <-- release PR dev->main <-- squash into dev <-- PR + checks
```
Labels: `agent:proposed` -> `agent:plan-ready` -> `agent:approved` -> `agent:in-progress` ->
`released` (closed). `agent:needs-human` means an agent is blocked.

- **Automatic plan:** a new `type:feature` or `type:bug` issue gets a plan from the planner agent
  (`plan-on-issue.yml`). Comment `replan <feedback>` for another version.
- **Approval:** an owner or maintainer comment starting with `approve`, `approved` or `lgtm` adds
  `agent:approved` and starts the build (`approve-on-comment.yml`).
- **Automatic build:** `agent-build.yml` runs Copilot CLI as the delivery-orchestrator with a read-only token,
  then the workflow opens the PR. GitHub holds CI on PRs opened by workflows: the owner clicks
  "Approve workflows to run". When the required checks pass, `agent-merge.yml` squash-merges into `dev`
  and keeps one `Release: dev -> main` PR up to date. Failures are retried, then `agent:needs-human`.
- **Release:** the owner merges the release PR or comments `ship` on it (`ship-on-comment.yml`).
  `web.yml` deploys; `release-closeout.yml` then closes the included issues with a "Released" comment.
- **Architect step:** PRs touching scripts, workflows, infra, API code, app services/data, pubspec or web
  hosting config need `## Architecture docs` in the PR body (`docs-check`).
- **Store builds** are manual: the owner archives, signs and submits (see the store-release skill).

## 4. Agents and skills
| Stage | Agent | Skills |
|---|---|---|
| Intake, routing | delivery-orchestrator | intake-to-issue |
| Plan | planner | implementation-plan |
| Implement | developer | feature-implementation, bug-fix-workflow, flutter-feature, api-endpoint, store-release |
| Tests | unit-test-author, integration-test-author | unit-test, integration-test |
| Docs | architect | architecture-docs |
| Review | reviewer | code-review |
| Git, PR, release | pr-release-manager | pull-request-workflow, release-and-deploy, store-release |
| Pipelines | cicd-ops | incident-triage, release-and-deploy |

Files: [.github/agents](../.github/agents/README.md), `.github/skills/`, registry in
[agent-platform](../agent-platform/README.md). Validate with `make agents-check`.

## 5. Guardrails and approvals
[guardrails.md](../agent-platform/policies/guardrails.md) lists what agents never do (secrets, direct pushes,
self-approval, store uploads) and what needs recorded owner approval (workflows, `infra/`, signing, new
services). [approvals.md](../agent-platform/policies/approvals.md) says who approves what. Automated builds
cannot change protected paths (`scripts/protected_paths.py`); the build stops if they try.

## 6. Evaluating agents
`agent-platform/evaluations/cases.yaml` holds expected behaviors. CI checks structure; run the cases of an
agent you change and record the result in the PR.
