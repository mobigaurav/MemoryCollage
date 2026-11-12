---
name: implementation-plan
description: "Write the implementation plan for issue #N and run the approval gate. USE WHEN: an issue needs a plan before coding, label agent:proposed, 'plan #N'."
argument-hint: "Issue number"
---

# Implementation Plan

Follow [AGENTS.md](../../../AGENTS.md) (branch flow, guardrails).

## Plan template (post as an issue comment titled `Implementation plan v<k>`)
```
Goal: <one sentence>
Size: S | M | L          Risk: low | medium | high
Files to change: <path> - <what>            (list every file)
Areas affected: <app | API | web | infra | scripts/workflows> - one line each
External services: <each third-party service the plan depends on (Cognito, AWS, RevenueCat, fal, Runway,
                    App Store, Play) with a link to its current docs checked today: still available?
                    deprecations? new keys or console settings a person must provision?>
API and data contract: <endpoints, request/response shapes, Drift or DynamoDB schema changes, migrations>
Store version: <none | bump pubspec to x.y.z+n, with the reason; privacy or review-notes impact>
Workflows/config/infra: <changes - protected paths need explicit approval>
Tests: unit - <cases>; integration - <cases>
Docs: <SYSTEM_DESIGN / BACKEND / README sections>
Rollout: <dev first; release PR to main; web deploys on merge to main; store build is an owner step>
Rollback: <revert PR / feature flag / previous store build>
Open questions: <numbered>
```
## Before posting
- Check the current status of every external service in the plan (docs or changelog, today's date). A
  retired or deprecated service is a blocker, not a footnote.
- Mark every protected path (`infra/`, workflows, signing, store credentials) as needing explicit approval.

## Gate
- Unattended (plan-on-issue.yml): the workflow script posts the plan and sets the labels; the agent only
  returns the plan text. The owner comments `approve`, or `replan <feedback>` for the next version.
- Add `agent:plan-ready`; ask "Approve, change, or reject?".
- Approval = requester or CODEOWNER comments approval or adds `agent:approved`. Record who and when in the issue.
- A changed plan = new version (`v2`) and re-approval.
