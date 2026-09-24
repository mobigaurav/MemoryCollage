# Memory Book (Flutter)

Cross-platform rebuild of MemoryCollage: a living photo book for iOS and Android, plus collage and memory-reel studios.

The original Swift app remains in the repo as layout-math reference. This app is the product going forward.

iOS release builds use the live bundle id `com.playingview.mobigaurav.MemoryCollage`, so the App Store app becomes Memory Book. Debug and Profile keep `com.playingview.mobigaurav.memoryBook` and install beside it. Android’s Play package is `com.playingview.mobigaurav.memorybook`.

Planning (source of truth for what we are building):

- [System design](docs/SYSTEM_DESIGN.md)
- [Product roadmap](docs/PRODUCT_ROADMAP.md)

## Stack

- Flutter 3 / Dart 3
- Riverpod, go_router, Drift
- RevenueCat (`purchases_flutter`) when `REVENUECAT_API_KEY` is set
- Native H.264 encoder (AVAssetWriter / MediaCodec) — no FFmpeg binary
- Sign in with Apple / Google and an AI credit ledger for v1.5 (optional)

## Run

Flutter is not required as a global install. This repo vendors the SDK at `.tools/flutter` (gitignored). From `memory_book`:

```bash
./flutterw pub get
./flutterw run
```

Or put it on your PATH for this terminal session:

```bash
export PATH="/Users/gauravkumar/Desktop/project/MemoryCollage/.tools/flutter/bin:$PATH"
flutter pub get
flutter run
```

The first onboarding pass demos the page-turn. Create a book from the shelf. Tap empty photo corners to fill a page. Share a spread or export a 9:16 flip reel.

Dev page-curl spike: open `/dev/curl` (from a debug shortcut, or `context.go('/dev/curl')`).

## Configuration

Pass dart-defines when you have keys:

```bash
flutter run --dart-define=REVENUECAT_APPLE_KEY=appl_xxx \
            --dart-define=REVENUECAT_GOOGLE_KEY=goog_xxx \
            --dart-define=AI_BASE_URL=https://api.example.com \
            --dart-define=COGNITO_CLIENT_ID=your_public_client_id \
            --dart-define=AWS_REGION=us-east-1 \
            --dart-define=GOOGLE_SERVER_CLIENT_ID=....apps.googleusercontent.com
```

`COGNITO_CLIENT_ID` is Memory Book’s own public app client (`USER_PASSWORD_AUTH` enabled). Leave it empty to create a local test account with welcome credits. Do not reuse another product’s pool.

`REVENUECAT_API_KEY` still works as a single-key fallback. The current offering should include an **annual** package (primary) and a **monthly** package, both granting the `premium` entitlement.

Dev unlock stays available until a store build passes `--dart-define=DEV_UNLOCK=false`. Without a RevenueCat key, the paywall's **Dev unlock** stores a local entitlement so you can test watermark removal.

Without `AI_BASE_URL`, the AI lab refunds the credit and offers the on-device Memory Reel. The API, Cognito stack, and marketing site live in [../docs/BACKEND.md](../docs/BACKEND.md).

## Store notes

See [store/ASO.md](store/ASO.md) and [store/PRIVACY.md](store/PRIVACY.md).

## Tests

```bash
flutter test
```
