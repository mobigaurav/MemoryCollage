# Memory Book backend and site

The phone stays the product. This stack is the account, the credit ledger, and the one photo someone sends for a clip. It is a separate Cognito pool from Arogya.

```
memory_book/     Flutter app
services/api/    FastAPI. Local ledger until Neon is connected.
infra/lite/      Cognito + API Gateway + Lambda + private S3
apps/web/        Next.js site for Vercel
```

## Run locally

```bash
cd services/api
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
ENV=dev uvicorn mb_api.main:app --reload --port 3013
```

`GET http://127.0.0.1:3013/health`

`POST /v1/ai/video` with `Authorization: Bearer dev` returns `fallbackToOnDevice` until `VIDEO_VENDOR` and `VIDEO_VENDOR_API_KEY` are set. The app then films the photo on the phone. `Bearer dev` works only when `ENV=dev`.

```bash
cd apps/web
npm install
npm run dev
```

Open http://localhost:3000

## Deployed dev stack

Stack `memorybook-lite-dev` in `us-east-1`.

- API: `https://z2k4sv0eoe.execute-api.us-east-1.amazonaws.com/dev`
- Cognito pool: `us-east-1_MkcAL7YNJ`
- App client: `thi97f481tevec4k8t7eibsf6`

```bash
cd memory_book
bash flutterw run
```

The app already has this API URL, the Cognito client id, and `us-east-1` in `memory_book/lib/core/config.dart`. Create account and sign-in call Cognito. A credit call hits this API. A phone cannot call `localhost` on your Mac.

## Deploy the site

Merging into `dev` runs [`.github/workflows/web.yml`](../.github/workflows/web.yml). That action links only to the Vercel project named `memory-book` and publishes https://memory-book-pearl-zeta.vercel.app. Add `VERCEL_TOKEN` on [MemoryCollage](https://github.com/mobigaurav/MemoryCollage). Optional: `VERCEL_ORG_ID` for the team. Do not set `VERCEL_PROJECT_ID`. A folder named `apps/web` plus `vercel --yes` will otherwise attach to another product's project `web`.

Store buttons appear when these Vercel env vars are set:

- `NEXT_PUBLIC_SITE_URL`
- `NEXT_PUBLIC_APP_STORE_URL`
- `NEXT_PUBLIC_PLAY_STORE_URL`

Pull requests also run API tests, the site build, Flutter analyze/test, and [Dock](https://pypi.org/project/dock-inbox/) (`.github/workflows/dock.yml`). Dock comments on the PR. It does not merge.

## What is still next

1. Point the Flutter credit number at `GET /v1/me` once the API is deployed.
2. Apply `services/api/schema.sql` on Neon and replace the in-memory ledger. A Lambda cold start forgets credits and in-flight clips until then.
3. `VideoVendor` is `runway`. The Runway secret is already a stack parameter. A later `sam deploy` keeps that secret. Pass `VideoVendorApiKey` only when you are replacing the key. A photo uses Gen-4 Turbo. Words alone use Gen-4.5.
4. Verify the RevenueCat webhook before it grants credits. The route answers and does not grant anything yet.
5. The phone already polls `GET /v1/ai/jobs/{id}` until the clip is ready.
6. Apple and Google sign-in go through this pool’s hosted UI (`memorybook-dev.auth.us-east-1.amazoncognito.com`), then return to `memorybook://auth`. A deploy with no Google or Apple parameters leaves those providers off and keeps any secret you already set. Pass `GoogleClientId` and `GoogleClientSecret`, or `AppleServicesId`, `AppleTeamId`, `AppleKeyId`, and `ApplePrivateKey`, only when connecting that provider. Register the stack output `CognitoIdpResponseUrl` as the Google redirect URI and the Apple Services ID return URL. Do not put those secrets in `samconfig.toml`.
