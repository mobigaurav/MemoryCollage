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
bash flutterw run --dart-define=AI_BASE_URL=https://z2k4sv0eoe.execute-api.us-east-1.amazonaws.com/dev \
  --dart-define=COGNITO_CLIENT_ID=thi97f481tevec4k8t7eibsf6 \
  --dart-define=AWS_REGION=us-east-1
```

A phone cannot call `localhost` on your Mac. Use this API URL for device tests.

## Deploy the site

Merging into `dev` runs [`.github/workflows/web.yml`](../.github/workflows/web.yml). That action deploys `apps/web` and creates the Vercel project on the first successful run. Add one GitHub Actions secret, `VERCEL_TOKEN`, on [MemoryCollage](https://github.com/mobigaurav/MemoryCollage). Optional later: `VERCEL_ORG_ID` and `VERCEL_PROJECT_ID`.

Store buttons appear when these Vercel env vars are set:

- `NEXT_PUBLIC_SITE_URL`
- `NEXT_PUBLIC_APP_STORE_URL`
- `NEXT_PUBLIC_PLAY_STORE_URL`

Pull requests also run API tests, the site build, Flutter analyze/test, and [Dock](https://pypi.org/project/dock-inbox/) (`.github/workflows/dock.yml`). Dock comments on the PR. It does not merge.

## What is still next

1. Point the Flutter credit number at `GET /v1/me` once the API is deployed.
2. Apply `services/api/schema.sql` on Neon and replace the in-memory ledger. A Lambda cold start forgets credits until then.
3. Add one image-to-video adapter behind `VIDEO_VENDOR`. The key stays in the stack parameter, never in the app.
4. Verify the RevenueCat webhook before it grants credits. The route answers and does not grant anything yet.
5. Poll `GET /v1/ai/jobs/{id}` from the app when a job is queued.
