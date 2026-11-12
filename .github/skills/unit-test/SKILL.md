---
name: unit-test
description: "Write unit tests for this repo (Flutter, API, scripts), in diff mode (code changed vs origin/dev) or full mode (named module). USE WHEN: unit-test-author is invoked; 'cover my diff', 'test module X'."
argument-hint: "diff | full <module>"
---

# Unit Test

Follow [AGENTS.md](../../../AGENTS.md) (branch flow, guardrails).

## Procedure
1. Scope: `git diff --name-only origin/dev...HEAD` (diff) or the named module (full). Pick the runner per path:
   - `memory_book/lib/**` -> `memory_book/test/*_test.dart` (`./flutterw test`); see `domain_test.dart` for style.
   - `services/api/mb_api/**` -> `services/api/tests/test_*.py` (`make api-test`); see `test_api.py`.
   - `scripts/**` -> `tests/test_*.py` (`pytest -q tests`).
2. Read the code and the nearest existing test for fixtures and style.
3. Tests per function: happy path, empty, error, null/zero, limits, boundary dates and time zones, free vs premium.
4. Mock network and cloud clients; use sanitized fixtures.
5. The runner must pass; `ruff check scripts tests` clean for Python in `scripts/` and `tests/`. Report cases added.
