---
name: api-endpoint
description: "Add or change an endpoint, store or model in the FastAPI service (services/api/mb_api) and keep the app contract and docs in sync. USE WHEN: new route, new field, auth or entitlement rule, DynamoDB or S3 access change."
argument-hint: "Endpoint or behavior"
---

# API Endpoint

Follow [AGENTS.md](../../../AGENTS.md) (branch flow, guardrails).

## Procedure
1. Read `docs/BACKEND.md` and the nearest router in `services/api/mb_api` (routers: ai, billing, community, health, household, library, me, notes, notifications).
2. Add the route to the matching router; validate input with typed models; require the Cognito JWT dependency unless the endpoint is public on purpose; scope data to the caller's user or household.
3. Storage goes through the existing store classes (DynamoDB tables, S3 media bucket); do not call AWS from routers directly. New tables, buckets or IAM permissions are `infra/lite` changes and need explicit owner approval.
4. Keep responses backward compatible with released app versions; add fields, do not rename or remove them.
5. Add a `TestClient` test in `services/api/tests/` (success, unauthorized, invalid input, not found); run `make api-test`.
6. Update `docs/BACKEND.md` and, if the app calls it, the client in `memory_book/lib/services/`.
