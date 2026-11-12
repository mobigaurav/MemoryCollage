# AGENTS.md - how AI agents work in this repo

Read this first. It applies to every AI runtime (GitHub Copilot Chat custom agents, the Copilot
coding agent, Cursor, or any other assistant). Agent and skill files are plain Markdown
so every runtime uses the same instructions.

## What this repo is
Memory Book (MemoryCollage): a Flutter app for iOS and Android that turns photos and notes into memory
videos and shared household albums, a Python FastAPI backend on AWS (Cognito, API Gateway, Lambda, S3,
DynamoDB), and a static marketing/support site on Vercel.
Architecture: [docs/SYSTEM_DESIGN.md](docs/SYSTEM_DESIGN.md), backend detail [docs/BACKEND.md](docs/BACKEND.md),
app design [memory_book/docs/SYSTEM_DESIGN.md](memory_book/docs/SYSTEM_DESIGN.md).
Agent workflow: [docs/AGENTIC_DEVELOPMENT.md](docs/AGENTIC_DEVELOPMENT.md); full design: [docs/AGENTIC_SYSTEM_DESIGN.md](docs/AGENTIC_SYSTEM_DESIGN.md);
owner setup: [docs/SETUP.md](docs/SETUP.md).

## Repo map
| Path | What |
|---|---|
| `memory_book/` | Flutter app (iOS/Android). Store version in `pubspec.yaml`. Tests in `memory_book/test/`. Store text in `memory_book/store/` |
| `services/api/` | FastAPI backend (`mb_api/`, `schema.sql`, `Dockerfile`, tests in `tests/`) |
| `apps/web/` | Static/Next.js site (npm), deployed to Vercel by `web.yml` |
| `infra/lite/` | AWS template (Cognito, API Gateway, Lambda, S3, DynamoDB). Owner-approved changes only |
| `scripts/` | Agent-flow helpers (stdlib plus `requests`): `validate_agents.py`, `check_docs.py`, `plan_gate.py`, `protected_paths.py`, `plan_issue.py`, `agent_build.py`, `release.py`, `approve_on_comment.py` |
| `tests/` | Unit tests for `scripts/` (pytest) |
| `.github/workflows/` | `ci.yml` (API, Web, Flutter, agents-check, branch-policy), `dock.yml`, `web.yml`, `docs-check.yml` (docs-check, plan-gate), `plan-on-issue.yml`, `agent-build.yml`, `agent-merge.yml`, `approve-on-comment.yml`, `ship-on-comment.yml`, `release-closeout.yml` |
| `.github/agents/`, `.github/skills/` | Agent and skill definitions (runtime files) |
| `agent-platform/` | Registry, policies, evaluation cases (control plane) |
| `docs/` | `SYSTEM_DESIGN.md`, `BACKEND.md`, `SETUP.md`, `AGENTIC_*.md`, `adr/` |
| `.cursor/rules/` | Cursor rules, including the branching rule |

## Commands
```bash
./flutterw pub get      # from memory_book/ or repo root wrapper; SDK lives in .tools/flutter (see memory_book/flutterw)
./flutterw analyze      # Flutter lint (must be clean)
./flutterw test         # Flutter tests
make api-test           # API tests (cd services/api && python -m pytest)
make api-dev            # run the API locally on port 3013
cd apps/web && npm ci && npm run build   # web build
make install            # dev tools for scripts/ (pytest, ruff, pyyaml, requests)
make test-scripts       # unit tests for scripts/ (pytest -q tests)
make agents-check       # validate agents, skills, registry, eval cases
ruff check scripts tests   # lint for the scripts (must be clean)
```
Python 3.12 or newer is needed for `scripts/` and `tests/`.

## Branches and flow (non-negotiable)
```
 prompt / chat / bug report
        |
        v
 GitHub Issue #N  --plan comment-->  label agent:approved (a person approves)
        |
        v
 DEV_<N>  (cut from dev)  --PR, squash-->  dev  --release PR, merge commit-->  main  --> site deploy (web.yml)
                                              ^
 hotfix/<N>-slug (from main) -----------------+------ PR to main, then back-merge main into dev
```
- Never commit to `main` or `dev` directly. Never force-push shared branches. Never use `--no-verify`.
- Every change starts from a GitHub Issue. If the user gives a prompt, create the issue first ([intake-to-issue](.github/skills/intake-to-issue/SKILL.md)).
- No code before the plan is approved: the issue needs the `agent:approved` label or an explicit approval from the requester in the conversation. The required `plan-gate` check blocks merging a PR into `dev` unless every linked issue (`DEV_<N>` branch, `Closes #N`) has `agent:approved`.
- PR title: `#<N>: <summary>`. PR body follows `.github/pull_request_template.md` and contains `Closes #<N>`.
- Agents open PRs and request review. Agents never approve their own PRs. Merging: a person merges, except the
  automated flow described in [approvals.md](agent-platform/policies/approvals.md).
- Merging `main` deploys the web site. App Store and Play builds are made and submitted by the owner only.

## Guardrails (summary of [agent-platform/policies/guardrails.md](agent-platform/policies/guardrails.md))
- Never read, print, log or commit secrets or signing files (keystores, `key.properties`, `.p8`, certificates, provisioning profiles, `.env`, `memory_book/store/credentials/`).
- Changes to `.github/workflows/`, `infra/`, rulesets, environments, secrets, signing or bundle ids need explicit human approval in the issue. The list of protected paths is `scripts/protected_paths.py`.
- Never send email or messages, or open issues on other repos, without approval.
- Behavior changes to the API, infra or app services must update the docs together (`docs/SYSTEM_DESIGN.md`, `docs/BACKEND.md`).
- The architect agent runs before every architecture-relevant PR and fills `## Architecture docs` in the PR
  body; the required `docs-check` job enforces it.
- Store version: bump `memory_book/pubspec.yaml` (build number strictly increasing) only when a store build ships ([store-release](.github/skills/store-release/SKILL.md)).
- User content (photos, notes) is private; never copy it into issues, logs or tests.

## Agents
| Agent | Use for |
|---|---|
| [delivery-orchestrator](.github/agents/delivery-orchestrator.agent.md) | Default entry point: prompt -> issue -> plan -> implement -> tests -> PR -> review -> release |
| [architect](.github/agents/architect.agent.md) | Architecture docs, design decisions (ADRs), keeping SYSTEM_DESIGN.md current |
| [planner](.github/agents/planner.agent.md) | Turn an issue into an implementation plan; approval gate |
| [developer](.github/agents/developer.agent.md) | Implement features and bug fixes per an approved plan |
| [unit-test-author](.github/agents/unit-test-author.agent.md) | Unit tests only |
| [integration-test-author](.github/agents/integration-test-author.agent.md) | Integration tests only |
| [reviewer](.github/agents/reviewer.agent.md) | Read-only adversarial PR review |
| [pr-release-manager](.github/agents/pr-release-manager.agent.md) | Branch, commits, PR to dev, review requests, dev->main release PR |
| [cicd-ops](.github/agents/cicd-ops.agent.md) | Workflows, failed-run triage, expired tokens, deployments |
