---
name: store-release
description: "Prepare an App Store and Google Play release: version bump rules, release notes, store listing impact. Never uploads or signs. USE WHEN: 'bump the version', 'prepare a store release', 'write release notes', a plan says a store build ships."
argument-hint: "Version and what changed"
---

# Store Release

Follow [AGENTS.md](../../../AGENTS.md) (branch flow, guardrails).

## Version rules
- The version lives in `memory_book/pubspec.yaml` as `version: <name>+<build>` and is shared by iOS and Android.
- The build number (after `+`) must strictly increase for every upload to either store, even for the same name.
- Name: patch for fixes, minor for features, major for large redesigns. Bump in the same PR as the change that ships, never in a drive-by.
- README mentions of the version must match `pubspec.yaml`; fix them when you bump.

## Release notes
- Draft short, user-facing notes (what changed for users, no internal jargon, no emojis) for App Store "What's New" and Play "Release notes"; put them in the PR body.
- Check `memory_book/store/ASO.md` and `memory_book/store/PRIVACY.md` when data collection, permissions or subscriptions change; flag any store-answer updates for the owner.

## Owner upload (Fastlane)
After the version bump merges, the **owner** builds and uploads with Fastlane (not agents):

- Android: `cd memory_book/android && bundle exec fastlane beta` (Play internal) or `release` (production)
- iOS: `cd memory_book/ios && bundle exec fastlane beta` (TestFlight) or `release` (App Store Connect, no auto-submit)
- Runbook: [memory_book/docs/FASTLANE.md](../../../memory_book/docs/FASTLANE.md)

Agents may document the commands and confirm `pubspec.yaml` was bumped; they must not execute upload lanes or touch credentials.

## Never
- Do not read, print or commit signing material: Android keystores and `key.properties`, iOS certificates, provisioning profiles, `.p8` keys, `memory_book/store/credentials/`, Fastlane AuthKeys or Play JSON under `fastlane/`.
- Do not upload builds, change store listings or answer privacy questionnaires. The owner runs Fastlane (or Xcode / Play Console) from their machine.
- Bundle ids (iOS release `com.playingview.mobigaurav.MemoryCollage`, Android `com.playingview.mobigaurav.memorybook`) and the Apple team are fixed; changing them is an owner decision.
