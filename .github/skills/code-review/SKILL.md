---
name: code-review
description: "Adversarial review checklist for PRs in this repo: Flutter app, FastAPI API, web, infra, store version. USE WHEN: reviewer agent runs, 'review PR #N', before opening a PR."
argument-hint: "PR number or diff"
---

# Code Review

Follow [AGENTS.md](../../../AGENTS.md) (branch flow, guardrails).

## Checklist
1. **Plan coverage:** every acceptance criterion done or explicitly deferred; nothing unplanned.
2. **Secrets and signing:** no keys, tokens, `.p8`, keystores, `key.properties`, `.env`, store credentials; no new protected path touched without recorded approval (`scripts/protected_paths.py`).
3. **API:** new or changed endpoints validate input, require auth (Cognito JWT) unless public on purpose, scope data to the caller (household, user), return stable shapes, and keep `docs/BACKEND.md` in sync.
4. **App:** state in Riverpod providers, routes in go_router, local data through Drift with migrations when the schema changes; no blocking work on the UI thread; works offline where the feature claims it; iOS and Android both considered.
5. **Entitlements and billing:** free vs premium limits enforced on the server, not only in the UI; RevenueCat identifiers come from config.
6. **Infra** (`infra/lite`): least-privilege IAM, no public buckets, no secrets in the template, cost impact stated; only with owner approval.
7. **Store version:** `memory_book/pubspec.yaml` bumped (build number strictly increasing) only when a store build ships; release notes drafted.
8. **Tests:** new logic covered; tests deterministic; the area's checks pass (analyze/test, `make api-test`, web build).
9. **Web:** static content accurate (privacy, support links), builds, nothing sensitive exposed.
10. **Docs:** SYSTEM_DESIGN/BACKEND/README updated when behavior changed; ASCII diagrams; no emojis.
Classify each finding Blocking / Non-blocking with file:line and a concrete fix.
