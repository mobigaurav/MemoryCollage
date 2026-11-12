---
name: intake-to-issue
description: "Turn a plain-language ask (prompt, chat request, email paste, bug report) into a well-formed GitHub Issue in mobigaurav/MemoryCollage. USE WHEN: someone asks for a feature, change or fix that has no issue yet."
argument-hint: "Request summary"
---

# Intake To Issue

Follow [AGENTS.md](../../../AGENTS.md) (branch flow, guardrails).

## Procedure
1. **Classify:** `type:feature`, `type:bug` or `type:chore`. A question the docs already answer is not an issue - answer it.
2. **Deduplicate:** `gh issue list -R mobigaurav/MemoryCollage --state all --search "<keywords>"`. If a match exists, comment on it with the new context instead.
3. **Write the issue** (use the matching template in `.github/ISSUE_TEMPLATE/`):
   - Title: imperative, under 70 characters ("Add album share button").
   - Body: `## Request` (the requester's words, quoted, with date and channel), `## Problem / goal`,
     `## Acceptance criteria` (checkboxes, testable), `## Out of scope`, `## Open questions`.
   - Never paste secrets, tokens or personal data (user photos, emails) from the request.
4. **Create:** `gh issue create -R mobigaurav/MemoryCollage --title ... --body-file ... --label "type:...,agent:proposed"`.
5. Report `#N` and the link to the requester, then hand to the planner.
