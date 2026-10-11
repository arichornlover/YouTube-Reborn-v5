#!/usr/bin/env bash
# Fetches the official Airbnb Lottie iOS binary (Lottie.xcframework.zip) and
# stages the device slice into Dependencies/Lottie/Lottie.framework so the
# SwiftUI menu can `canImport(Lottie)` and animate like Reborn's logo.
#
#   Tools/fetch-lottie.sh [version]
#
# The version defaults to 4.6.0. When Lottie is NOT staged the menu compiles
# and runs with the built-in SwiftUI fallback animation, so this script is
# strictly an opt-in enhancement.
#
# NOTE: Lottie.framework is a dynamic framework. Staging it links the module
# into the tweak, but jailed app builds must also embed the framework binary
# (e.g. via YouTubeReborn_LINK_FRAMEWORKS / _EMBED_FRAMEWORKS or by staging
# it into Bundles/YouTubeRebornMedia.bundle) or the app will fail to launch.
# The CI workflows default include_lottie to false and rely on the fallback.
#
# Adapted from the pattern used by Tools/stage-ffmpeg.sh.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
VERSION="${1:-4.6.0}"

DEST="$ROOT/Dependencies/Lottie"
CACHE_DIR="$ROOT/.cache/lottie"
TMP_DIR="$CACHE_DIR/fetch-$VERSION"
ZIP="$TMP_DIR/Lottie.xcframework.zip"
XCFRAMEWORK="$TMP_DIR/Lottie.xcframework"

FRAMEWORK_NAME="Lottie.framework"
FRAMEWORKS=(Lottie)

die()  { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }
info() { printf '\033[36m==>\033[0m %s\n' "$*"; }

command -v unzip >/dev/null 2>&1 || die "unzip is required (brew install unzip)"

URL="https://github.com/airbnb/lottie-ios/releases/download/$VERSION/Lottie.xcframework.zip"

mkdir -p "$DEST" "$TMP_DIR"

if [ ! -f "$ZIP" ]; then
  info "downloading Lottie $VERSION ($URL)"
  curl -fL --retry 3 -o "$ZIP" "$URL"
fi

info "unpacking $ZIP"
rm -rf "$XCFRAMEWORK"
unzip -q -o "$ZIP" -d "$TMP_DIR"
[ -d "$XCFRAMEWORK" ] || die "could not find Lottie.xcframework in the archive"

# Pick the iOS device slice. Prefer the exact `ios-arm64` slice and NEVER
# stage the simulator or Mac Catalyst slices: Catalyst ships a versioned
# framework (Versions/A + symlinks) whose symlink layout breaks `-f` checks
# and confuses the linker.
device_slices() {
  find "$XCFRAMEWORK" -maxdepth 1 -type d -name 'ios-*' | grep -Ev 'simulator|maccatalyst' || true
}
SLICE="$(device_slices | grep -x "$XCFRAMEWORK/ios-arm64" | head -n 1 || true)"
[ -n "$SLICE" ] || SLICE="$(device_slices | head -n 1)"
[ -n "$SLICE" ] && [ -d "$SLICE" ] || die "no iOS device slice found in $XCFRAMEWORK"
[ -d "$SLICE/$FRAMEWORK_NAME" ] || die "device slice $SLICE does not contain $FRAMEWORK_NAME"

info "staging $FRAMEWORK_NAME into ${DEST#"$ROOT/"}"
rm -rf "$DEST/$FRAMEWORK_NAME"
cp -RL "$SLICE/$FRAMEWORK_NAME" "$DEST/$FRAMEWORK_NAME"
rm -rf "$DEST/$FRAMEWORK_NAME/_CodeSignature"
rm -f "$DEST/$FRAMEWORK_NAME/Info.plist"

BINARY="$DEST/$FRAMEWORK_NAME/$FRAMEWORK_NAME"
if [ -f "$BINARY" ] && command -v ldid >/dev/null 2>&1; then
  ldid -S "$BINARY" 2>/dev/null || true
fi

if [ ! -f "$BINARY" ] || [ ! -s "$BINARY" ]; then
  printf '\033[31merror:\033[0m Lottie binary missing after staging (%s)\n' "$BINARY" >&2
  ls -la "$DEST/$FRAMEWORK_NAME" >&2 || true
  die "staging failed"
fi
SIZE="$(wc -c < "$BINARY" 2>/dev/null || true)"
info "Lottie $VERSION ready at ${DEST#"$ROOT/"}/$FRAMEWORK_NAME ($SIZE bytes)"