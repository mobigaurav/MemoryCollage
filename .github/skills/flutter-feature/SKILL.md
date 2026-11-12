---
name: flutter-feature
description: "Add or change a screen, widget, provider or local-data table in the Flutter app (memory_book/) following the house style. USE WHEN: UI or app-logic work; new screen, setting, paywall change, Drift table, go_router route."
argument-hint: "Feature or screen"
---

# Flutter Feature

Follow [AGENTS.md](../../../AGENTS.md) (branch flow, guardrails).

## Procedure
1. Read `memory_book/docs/SYSTEM_DESIGN.md` and the nearest similar screen under `memory_book/lib/`.
2. State in Riverpod providers; routes in go_router; remote calls through `lib/services/*`; local persistence through Drift in `lib/data/*`. A Drift schema change needs a version bump and a migration step.
3. Configuration (API base URL, Cognito and RevenueCat identifiers) comes from `lib/core/config.dart`; never hardcode secrets or add keys to the repo.
4. UI: reuse existing widgets and theme, handle loading, empty and error states, support small phones and large text, no emojis in UI strings or docs.
5. Validate: `./flutterw analyze` (flutter_lints must be clean) and `./flutterw test`; add or update a test in `memory_book/test/`.
6. Do not bump the version in `pubspec.yaml` unless the plan says a store build ships ([store-release](../store-release/SKILL.md)).
