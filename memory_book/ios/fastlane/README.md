# iOS Fastlane

See [../docs/FASTLANE.md](../../docs/FASTLANE.md).

```bash
cd memory_book/ios
bundle install
bundle exec fastlane build
bundle exec fastlane beta      # upload to TestFlight
bundle exec fastlane release   # upload to App Store Connect (no review submit)
```
