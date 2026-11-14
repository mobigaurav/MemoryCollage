# System design

Short map of how Memory Book is built today. The code is the source of truth. Details live in
[BACKEND.md](BACKEND.md) (API and AWS) and [memory_book/docs/SYSTEM_DESIGN.md](../memory_book/docs/SYSTEM_DESIGN.md) (app).
How agents build and ship changes is in [AGENTIC_DEVELOPMENT.md](AGENTIC_DEVELOPMENT.md).

## 1. Overview
```
 +--------------------+        HTTPS + Cognito JWT         +-------------------------------+
 | memory_book/       | ----------------------------------> | API Gateway (RestApi)         |
 | Flutter app        |                                     |   -> Lambda (ApiFunction)     |
 | iOS / Android      | <---------------------------------- |      services/api  mb_api     |
 |                    |        JSON, presigned URLs         +--------+----------+-----------+
 | Riverpod, go_router|                                              |          |
 | Drift (local DB)   |   sign-in (Cognito Hosted UI,        +-------v--+  +----v-----------+
 | native H.264 export|   Google / Apple providers)          | DynamoDB |  | S3 MediaBucket |
 +----+----------+----+                                      | Household|  | (private)      |
      |          |                                           | Community|  +----------------+
      |          +--> RevenueCat (subscriptions)             +----------+
      |                                                       video vendors (fal / Runway) are
      +--> on-device fallback when the API says so            optional, set by env vars
 +--------------------+
 | apps/web/ Next.js  |  marketing, privacy, support pages -> Vercel project `memory-book`
 +--------------------+
```

## 2. Components
- **App (`memory_book/`)**: Flutter. State in Riverpod providers (`lib/providers.dart`), routes in go_router
  (`lib/app.dart`), local data in Drift (`lib/data`), services in `lib/services` (Cognito sign-in
  `cognito_auth.dart`, API clients such as `household_api.dart` and `community_api.dart`, credits, premium,
  export and video rendering, notifications). Endpoint URLs and identifiers are in `lib/core/config.dart`.
  Store version is `version:` in `pubspec.yaml`, shared by iOS and Android.
- **API (`services/api/mb_api`)**: FastAPI app built in `main.py`, wrapped for Lambda by `handler.py` (Mangum).
  Routers: health, community, household, notes, library, me, ai, billing (RevenueCat webhook), notifications.
  Auth: Cognito JWT (`auth.py`); `ENV=dev` allows a dev token. Stores: household, community, notes and library
  stores for DynamoDB and S3; `store.py` is an in-memory credit ledger and job list (resets on cold start;
  `schema.sql` is the planned relational shape). `POST /v1/ai/video` uses `fal_video.py` or `runway_video.py`
  when `VIDEO_VENDOR` is set, otherwise returns `fallbackToOnDevice` and the app renders on the phone.
- **Infra (`infra/lite/template.yaml`)**: stack `memorybook-lite-dev` in `us-east-1`: Cognito user pool, client,
  domain and Google/Apple identity providers; private S3 MediaBucket; DynamoDB HouseholdTable and CommunityTable;
  the Lambda ApiFunction and RestApi.
- **Web (`apps/web`)**: Next.js pages (about, blog, contact, features, privacy, support, terms, delete-account) built with npm. `/delete-account` is the public page for the store account-deletion link.

## 3. Delivery and CI/CD
```
 DEV_<N> --PR--> dev --release PR--> main --push--> web.yml --> Vercel (site)
    |              |                   |
    +--- ci.yml: API | Web | Flutter | agents-check | branch-policy
    +--- docs-check.yml: docs-check | plan-gate
    +--- dock.yml: claim report comment (never merges)
```
- `ci.yml` runs on pull requests and on pushes to `dev` and `main`: API (pytest), Web (npm build), Flutter
  (`flutter analyze`, `flutter test`, Flutter 3.47.5), agents-check (ruff and pytest for `scripts/` and `tests/`,
  agent validation), branch-policy (which branch may target which).
- `web.yml` deploys the site only when `main` changes (or is dispatched); it needs `VERCEL_TOKEN`.
- The API and AWS stack are deployed by hand from `infra/lite` (no workflow deploys them).
- Store builds (App Store, Play) are made and submitted by the owner. The agent workflows are described in
  [AGENTIC_SYSTEM_DESIGN.md](AGENTIC_SYSTEM_DESIGN.md).

## 4. Security
- Secrets live in GitHub repository secrets, AWS and the owner's machine; none are committed.
  Signing files and store credentials are protected paths (`scripts/protected_paths.py`).
- API data is scoped by the Cognito subject (user, household). Media is in a private bucket.
- Agents cannot change `.github/workflows/`, `infra/` or signing files without recorded owner approval.

## 5. Failure modes
| Failure | Effect | Handling |
|---|---|---|
| Video vendor not configured or failing | No cloud clip | API returns `fallbackToOnDevice`; app renders locally |
| Lambda cold start | In-memory ledger resets | Known limitation until the relational store ships |
| `VERCEL_TOKEN` missing | Site not deployed | `web.yml` exits without deploying; add the secret |
| Agent flow disabled | No automatic plans or builds | Repo variable `AGENT_BUILD_ENABLED=false`; work continues by hand |
