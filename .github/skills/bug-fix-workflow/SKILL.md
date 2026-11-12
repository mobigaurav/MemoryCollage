---
name: bug-fix-workflow
description: "Diagnose and fix a bug: wrong value, crash, broken screen, failing endpoint, failed run. Reproduce first, find root cause, add a regression test, minimal fix. USE WHEN: issue type:bug, 'this is wrong', 'the app crashes', 'the endpoint returns 500'."
argument-hint: "Issue number and symptom"
---

# Bug Fix Workflow

Follow [AGENTS.md](../../../AGENTS.md) (branch flow, guardrails).

## Procedure
1. **Reproduce:** app bug = failing widget or domain test (`./flutterw test`) or exact steps on a simulator; API bug = failing `TestClient` test (`make api-test`); web bug = `npm run build` or the page; CI bug = `gh run view <id> --log-failed`. Write down expected vs actual.
2. **Localize:** which layer? App state/UI, API router or store, Cognito/AWS config, web page. Check entitlement (free vs premium), time zones, empty and null data, platform differences (iOS vs Android).
3. **Root cause** in one sentence in the issue before fixing.
4. **Regression test** that fails before the fix (ask unit-test-author or write the minimal one with the fix).
5. **Fix** minimally. Data migrations or infra changes are separate, owner-approved steps; say so in the PR.
6. **Verify** with the repro and the area's checks; post before/after on the issue.
