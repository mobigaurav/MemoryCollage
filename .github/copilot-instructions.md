# Copilot instructions

Follow [AGENTS.md](../AGENTS.md) - it is the single source of truth for every AI runtime in this repo
(branch flow, guardrails, commands, agent index). Custom agents are in `.github/agents/`, reusable
workflows in `.github/skills/`.

Unattended runs: `plan-on-issue.yml` runs the `planner` agent and `agent-build.yml` runs
the `delivery-orchestrator` agent through Copilot CLI in GitHub Actions. In those runs, follow the
agent file's "Unattended mode" section: no git or GitHub commands, no protected paths
(`scripts/protected_paths.py`), output files under `.agent-out/`.

Code conventions:
- Flutter (`memory_book/`): Dart with `flutter_lints` clean (`./flutterw analyze`), Riverpod for state,
  go_router for routes, Drift for local data; configuration in `lib/core/config.dart`, never secrets in code.
- API (`services/api`): FastAPI with typed models; Cognito JWT auth; storage through the store classes;
  tests with `TestClient` (`make api-test`); keep `docs/BACKEND.md` in sync.
- Web (`apps/web`): `npm ci && npm run build` must pass.
- Scripts (`scripts/`, `tests/`): Python 3.12, `ruff check scripts tests` clean (config in `pyproject.toml`),
  standard library first (`requests` and `pyyaml` only where already used); new dependencies need a reason in the PR.
- No emojis in UI, docs or commit messages.
- Docs use ASCII diagrams (Mermaid does not render for our GitHub setup).
