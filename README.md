# Memory Book

A photo book that lives on the phone, with a collage studio and films made on the device. The store name is Memory Book on iOS and Android.

The old Swift app is no longer in this tree. Its history is still in git if a layout needs to be checked.

## Layout

| Path | What it is |
| --- | --- |
| [`memory_book/`](memory_book/README.md) | Flutter app for iOS and Android |
| [`apps/web/`](apps/web) | The public site |
| [`services/api/`](services/api) | The API: accounts, credits, family books, and one photo sent for a clip |
| [`infra/lite/`](infra/lite) | Cognito, API Gateway, Lambda, and the private media bucket |
| [`docs/BACKEND.md`](docs/BACKEND.md) | How the API is run and where dev is deployed |

iOS release builds keep the live bundle id `com.playingview.mobigaurav.MemoryCollage`, so this update replaces the app already on the App Store. Debug and Profile use `com.playingview.mobigaurav.memoryBook` and install beside it. Android is a new Play listing, `com.playingview.mobigaurav.memorybook`.

The store version lives in `memory_book/pubspec.yaml` as `version: 2.0.0+7` (name `2.0.0`, build `7`). iOS and Android stay on that same pair. In Xcode, leave Manage Version off so an archive keeps those numbers.

## Setup

Xcode is required for the iOS simulator and for archives. Android Studio (or the Android SDK) is required for an Android build. Flutter is not installed globally. The SDK is cloned into `.tools/flutter`, which is gitignored.

From the repo root, once:

```bash
git clone --depth 1 -b stable https://github.com/flutter/flutter.git .tools/flutter
```

Then, from the repo root:

```bash
./flutterw pub get
```

`./flutterw` is the Flutter command for this repo. It runs inside `memory_book`, where the phone app lives. The commands below are from the repo root.

## Run

`run` compiles, installs, and opens the app, and stays attached. `build` only writes the file.

Debug is the day-to-day run. It hot reloads. Profile does not. Release is the store build.

```bash
./flutterw devices
./flutterw run
```

Leave that terminal open. `r` hot reloads a Dart change, `R` restarts the app, `q` quits. A native change, or a compile-time flag, needs `R`.

To pick a simulator:

```bash
./flutterw run -d "iPhone 16"
```

A profile run on a phone is closer to a store build. It does not hot reload:

```bash
./flutterw run --profile
```

## Build, then Run from Xcode

This writes a Debug simulator app. Hot reload still needs the Flutter tool attached.

```bash
./flutterw build ios --debug --simulator
```

Open `memory_book/ios/Runner.xcworkspace`. Scheme **Runner**, destination an iPhone simulator, Run configuration **Debug**, then Product → Run. With that app open:

```bash
./flutterw attach
```

`r` hot reloads, `R` restarts.

## Store builds

Upload a Release build only. A Debug or Profile install uses the other bundle id and is not the store binary.

iOS: open `Runner.xcworkspace`, scheme **Runner**, destination **Any iOS Device**, configuration **Release**. Product → Archive, then upload from the Organizer. Team `C6E94YDVFW`.

Android:

```bash
./flutterw build appbundle --release
```

The Play file is `memory_book/build/app/outputs/bundle/release/app-release.aab`.

## Checks

```bash
./flutterw analyze
./flutterw test
```

## API and site

From the repo root:

```bash
make api-dev
make api-test
make web-dev
```

## License

MIT. See [LICENSE](LICENSE).
