#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${OUTPUT_DIR:-$ROOT/dist}"
RELEASE_BUILD="${BUILD_DIR:-$(mktemp -d /private/tmp/codex-pets-release.XXXXXX)}"
VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$ROOT/Info.plist")
if [[ "${SKIP_BUILD:-0}" != 1 ]]; then BUILD_DIR="$RELEASE_BUILD" bash "$ROOT/build.sh"; fi
python3 "$ROOT/scripts/check-package.py" "$RELEASE_BUILD/Codex Pets.app"
python3 -c 'import ds_store, mac_alias'
mkdir -p "$OUT"
STAGE=$(mktemp -d /private/tmp/codex-pets-dmg-stage.XXXXXX)
MOUNT=$(mktemp -d /private/tmp/codex-pets-dmg-volume.XXXXXX)
cleanup() {
 hdiutil detach "$MOUNT" -quiet >/dev/null 2>&1 || true
 rm -rf "$STAGE" "$MOUNT"
}
trap cleanup EXIT
CONTENTS="$STAGE/contents"
mkdir -p "$CONTENTS/.background"
ditto --noextattr --norsrc --noqtn "$RELEASE_BUILD/Codex Pets.app" "$CONTENTS/Codex Pets.app"
ln -s /Applications "$CONTENTS/Applications"
cp -X "$ROOT/docs/install/Installation-Guide.pdf" "$CONTENTS/安装指南 Installation Guide.pdf"
cp -X "$ROOT/docs/install/dmg-background.png" "$CONTENTS/.background/install.png"
hdiutil create -volname 'Codex Pets' -srcfolder "$CONTENTS" -format UDRW -fs HFS+ -ov "$STAGE/installer-rw.dmg" -quiet
hdiutil attach "$STAGE/installer-rw.dmg" -mountpoint "$MOUNT" -nobrowse -noautoopen -quiet
python3 "$ROOT/scripts/configure-dmg.py" "$MOUNT"
hdiutil detach "$MOUNT" -quiet
NAME="Codex-Pets-$VERSION-arm64.dmg"
hdiutil convert "$STAGE/installer-rw.dmg" -format UDZO -imagekey zlib-level=9 -ov -o "$OUT/$NAME" -quiet
(cd "$OUT" && shasum -a 256 "$NAME" > "$NAME.sha256")
echo "$OUT/$NAME"
