# Memory Book — Fastlane (Flutter)

Owner-run store builds and uploads for iOS and Android. Agents never run these
lanes and never read signing material.

This is **Flutter**, not React Native: Fastlane uploads artifacts that
`flutterw` already built ([Flutter continuous delivery](https://docs.flutter.dev/deployment/cd)).

## Layout

| Path | Role |
| --- | --- |
| `memory_book/android/fastlane/` | Play App Bundle build + `upload_to_play_store` |
| `memory_book/ios/fastlane/` | IPA build + TestFlight / App Store Connect upload |
| `memory_book/android/build-release.sh` | Thin wrapper → Android `fastlane build` |

Version / build number always come from `memory_book/pubspec.yaml`
(`version: x.y.z+n`). Bump with the [store-release](../../.github/skills/store-release/SKILL.md)
skill before a store upload.

## One-time setup

```bash
# From the machine that signs and uploads (typically macOS):
cd memory_book/android && bundle install
cd ../ios && bundle install
```

### Android

1. `cp memory_book/android/keystore.properties.template memory_book/android/keystore.properties`
2. Place the upload keystore at `memory_book/android/app/<storeFile>` (same layout as Vedic / Arogya).
3. Put the Play Console service-account JSON at
   `memory_book/store/credentials/play.json` (gitignored), or set `PLAY_JSON_KEY_PATH`.

### iOS

1. Export an App Store Connect API key (`.p8`). Set:

   - `APP_STORE_CONNECT_API_KEY_ID`
   - `APP_STORE_CONNECT_API_ISSUER_ID`
   - `APP_STORE_CONNECT_API_KEY` (PEM text; or base64 + `APP_STORE_CONNECT_API_KEY_IS_BASE64=true`)

2. Signing (pick one):

   - **Automatic** (Xcode on your Mac): enough for `fastlane build` when your
     keychain already has a distribution cert for
     `com.playingview.mobigaurav.MemoryCollage`.
   - **match** (PulseMind-style): set `MATCH_PASSWORD`, and either SSH access to
     the certs repo or `CERTS_REPO_PAT` / `MATCH_GIT_BASIC_AUTHORIZATION`.
     Override the repo with `MATCH_GIT_URL` (default
     `https://github.com/mobigaurav/pulse-certificates.git`).

Team id is `C6E94YDVFW`. Release bundle id is
`com.playingview.mobigaurav.MemoryCollage`.

## Lanes

### Android (`memory_book/android`)

```bash
cd memory_book/android
bundle exec fastlane build     # signed AAB only
bundle exec fastlane beta      # build + upload (default track: internal)
bundle exec fastlane release   # build + upload to production
```

Optional env:

- `PLAY_TRACK` — override beta track (`internal`, `alpha`, `beta`, …)
- `PLAY_RELEASE_STATUS` — default `completed`
- `PLAY_UPLOAD_CHANGELOGS=1` — also push changelogs

Or: `./build-release.sh` (build only).

### iOS (`memory_book/ios`)

```bash
cd memory_book/ios
bundle exec fastlane build     # flutterw build ipa
bundle exec fastlane beta      # build + TestFlight
bundle exec fastlane release   # build + App Store Connect (no submit for review)
```

Optional env:

- `TESTFLIGHT_CHANGELOG`
- `MATCH_READONLY=0` — allow match to create/update certs/profiles
- `FLUTTER_ROOT` — Flutter SDK root if your shell does not already expose it

## Identifiers

| Store | Id |
| --- | --- |
| Play | `com.playingview.mobigaurav.memorybook` |
| App Store (Release) | `com.playingview.mobigaurav.MemoryCollage` |

## CI note

Repo policy keeps Apple / Play secrets off agent workflows (`docs/SETUP.md`).
These lanes are for the owner machine (or a future `main`-only Fastlane job after
an explicit secrets policy change). Do not commit keystores, `.p8` keys, Play JSON,
or match passwords.
