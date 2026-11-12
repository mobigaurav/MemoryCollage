---
name: integration-test
description: "Write integration tests that run modules together offline: API routers through TestClient, Flutter widget flows with fakes, workflow-level scripts. USE WHEN: integration-test-author is invoked; a change spans layers or touches workflows."
argument-hint: "Feature or flow under test"
---

# Integration Test

Follow [AGENTS.md](../../../AGENTS.md) (branch flow, guardrails).

## Levels
1. **API:** `TestClient(mb_api.main.app)` with in-memory stores and a stubbed auth dependency; walk a flow (create household, add note, list) and assert status codes and bodies. Put tests in `services/api/tests/`, reusing the style of `test_api.py`.
2. **App:** widget tests in `memory_book/test/` with Riverpod overrides and fake repositories; pump a screen, interact, assert visible state (empty, loading, error, premium gate).
3. **Scripts and workflows:** functions the workflows call (`scripts/release.py`, `scripts/agent_build.py`) with a fake GitHub client, in `tests/integration/`.
## Rules
No live services, no secrets, deterministic, under 60 s total. Run `make api-test`, `./flutterw test`, `pytest tests/integration -q` as applicable.
