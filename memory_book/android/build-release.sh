#!/bin/bash
# Memory Book — signed Play Store AAB.
# Adapted from Arogya's apps/mobile/android/build-release.sh.
# Run from memory_book/android: ./build-release.sh
#
# This app is Flutter, so the bundle is built with flutterw (the Android
# signing block still reads keystore.properties, same as Arogya).

set -euo pipefail

echo "Memory Book — Play Store release build"
echo "======================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -z "${JAVA_HOME:-}" ]; then
  for candidate in \
    "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home" \
    "/Applications/Android Studio.app/Contents/jbr/Contents/Home" \
    "/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home" \
    "/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home"
  do
    if [ -d "$candidate" ]; then
      export JAVA_HOME="$candidate"
      break
    fi
  done
fi

if [ -z "${JAVA_HOME:-}" ] || [ ! -x "$JAVA_HOME/bin/java" ]; then
  echo "Error: JAVA_HOME not set. Install JDK 17 and export JAVA_HOME."
  exit 1
fi

echo "Java: $JAVA_HOME"
"$JAVA_HOME/bin/java" -version 2>&1 | head -1
echo ""

if [ ! -f "keystore.properties" ]; then
  echo "Error: keystore.properties not found"
  echo "  cp keystore.properties.template keystore.properties"
  echo "  then fill storePassword / keyPassword"
  exit 1
fi

KEYSTORE_FILE=$(grep '^storeFile=' keystore.properties | cut -d= -f2 | tr -d '[:space:]')
if [ -z "$KEYSTORE_FILE" ] || [ ! -f "app/$KEYSTORE_FILE" ]; then
  echo "Error: keystore missing at app/${KEYSTORE_FILE:-<storeFile>}"
  exit 1
fi
echo "Keystore: app/$KEYSTORE_FILE"
echo ""

if [ ! -x "$APP_DIR/flutterw" ]; then
  echo "Error: $APP_DIR/flutterw is missing"
  exit 1
fi

echo "Building signed release AAB…"
cd "$APP_DIR"
./flutterw build appbundle --release

AAB="$APP_DIR/build/app/outputs/bundle/release/app-release.aab"
if [ ! -f "$AAB" ]; then
  echo "Build failed — AAB not found"
  exit 1
fi

echo ""
echo "Build successful"
echo "  AAB: $AAB"
echo "  Size: $(du -h "$AAB" | cut -f1)"
echo ""

if jarsigner -verify "$AAB" >/dev/null 2>&1; then
  echo "Signature: verified"
else
  echo "Warning: jarsigner could not verify (Play may still accept it)"
fi

echo ""
echo "Next:"
echo "  1. Play Console → Memory Book (com.playingview.mobigaurav.memorybook)"
echo "  2. Release → Testing or Production → Create release"
echo "  3. Upload the AAB above"
echo ""
