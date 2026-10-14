# Memory Book (Flutter)

The Memory Book phone app for iOS and Android: a photo book, a collage studio, and films made on the device.

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

The first onboarding pass demos the page-turn. Create a book from the shelf. Tap empty photo corners to fill a page. Finished films and AI clips live on the Reels tab.

## Configuration

Pass dart-defines when you have keys:

```bash
flutter run --dart-define=REVENUECAT_APPLE_KEY=appl_xxx \
            --dart-define=REVENUECAT_GOOGLE_KEY=goog_xxx \
            --dart-define=GOOGLE_SERVER_CLIENT_ID=....apps.googleusercontent.com
```

The API URL, Cognito client id, and region already live in `lib/core/config.dart`. `bash flutterw run` signs up through that pool. Do not reuse another product’s pool.

`REVENUECAT_API_KEY` still works as a single-key fallback. The current offering should include an **annual** package (primary) and a **monthly** package, both granting the `premium` entitlement.

Dev unlock stays available until a store build passes `--dart-define=DEV_UNLOCK=false`. Without a RevenueCat key, the paywall's **Dev unlock** stores a local entitlement so you can test watermark removal.

A credit call goes to the API in [../docs/BACKEND.md](../docs/BACKEND.md). Until a video vendor is attached, the phone films the clip itself.

## Store notes

See [store/ASO.md](store/ASO.md) and [store/PRIVACY.md](store/PRIVACY.md).

## Tests

```bash
flutter test
```
