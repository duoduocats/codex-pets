#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD="${BUILD_DIR:-$(mktemp -d /private/tmp/codex-pet-store-build.XXXXXX)}"
APP="$BUILD/Codex Pets.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
ICON_COMPILER="${ICON_COMPILER:-$(xcrun --find actool 2>/dev/null || true)}"
if [[ ! -x "$ICON_COMPILER" && -x /Applications/Xcode.app/Contents/Developer/usr/bin/actool ]]; then
  ICON_COMPILER=/Applications/Xcode.app/Contents/Developer/usr/bin/actool
fi
if [[ ! -x "$ICON_COMPILER" ]]; then
  echo 'Xcode 26 or later is required to compile the native app icon.' >&2
  exit 1
fi
mkdir -p "$BUILD/icon-assets"
"$ICON_COMPILER" "$ROOT/Resources/AppIcon.icon" --compile "$BUILD/icon-assets" \
 --platform macosx --minimum-deployment-target 13.0 --app-icon AppIcon \
 --output-partial-info-plist "$BUILD/icon-info.plist" --output-format human-readable-text
cp "$BUILD/icon-assets/Assets.car" "$BUILD/icon-assets/AppIcon.icns" "$APP/Contents/Resources/"
swiftc -module-cache-path "$BUILD/module-cache" -swift-version 5 -Osize -target arm64-apple-macosx13.0 \
 -framework AppKit -framework SwiftUI "$ROOT"/Sources/*.swift -o "$APP/Contents/MacOS/CodexPets"
strip -x "$APP/Contents/MacOS/CodexPets"
cp "$ROOT/Info.plist" "$APP/Contents/Info.plist"
cp "$ROOT/Resources/PetMark.png" "$APP/Contents/Resources/"
cp "$ROOT/LICENSE" "$APP/Contents/Resources/LICENSE.txt"
cp "$ROOT/THIRD_PARTY_NOTICES.md" "$APP/Contents/Resources/THIRD_PARTY_NOTICES.md"
codesign --force --sign - "$APP"
codesign --verify --deep --strict "$APP"
printf '%s\n' "$APP"
