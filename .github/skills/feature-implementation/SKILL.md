---
name: feature-implementation
description: "Implement an approved feature end to end in this repo (Flutter app -> API -> web -> docs). USE WHEN: issue #N is approved and is a feature; 'implement', 'add', 'build'."
argument-hint: "Issue number"
---

# Feature Implementation

Follow [AGENTS.md](../../../AGENTS.md) (branch flow, guardrails).

## Procedure
1. **Locate** the layer(s): UI and state = `memory_book/lib` ([flutter-feature](../flutter-feature/SKILL.md)); server logic = `services/api/mb_api` ([api-endpoint](../api-endpoint/SKILL.md)); marketing pages = `apps/web/src`; AWS resources = `infra/lite` (owner approval); workflows (owner approval).
2. **Trace** an existing similar feature end to end (screen -> provider -> service -> endpoint -> store) and copy its pattern.
3. **Implement** the smallest correct change. Order: API contract first (so app and API agree), then app, then web, then docs.
4. **Validate:** `./flutterw analyze`, `./flutterw test`, `make api-test`, `cd apps/web && npm ci && npm run build` for the areas touched, plus `ruff check scripts tests` if scripts changed. Run the app on a simulator when UI changed, if available.
5. **Hand off** to test authors, the architect and the reviewer; list anything not done.
