#!/usr/bin/env bash
# Stages FFmpegKitNext frameworks into Bundles/uYouMedia.bundle before packaging.
#
# Run automatically by the Makefile's before-package:: hook with the source
# Bundles/ directory as $1. Theos-jailed embeds $(TWEAK_NAME)_EMBED_BUNDLES from
# the source tree during internal-package (ipa.sh), so the frameworks must be in
# the bundle BEFORE that. Frameworks come from modules/ffmpeg (built by
# tools/fetch-ffmpegkit.sh) when present, otherwise from Vendor/.
#
# With no frameworks this FAILS the build: shipping a uYouEnhanced without a
# transcoding backend produces exactly the silent "conversion fails" broken
# downloads this repo has been shipping. Set UYOUSTAGE_ALLOW_MISSING=1 to degrade.
#
# Ported from YouMod's tools/stage-ffmpeg.sh.
set -euo pipefail

STAGING="${1:?usage: stage-ffmpeg.sh <bundle search root, e.g. Bundles>}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

BUNDLE_NAME="YouTubeRebornMedia.bundle"
# No Info.plist on purpose: this bundle only ever holds frameworks, and the
# runtime resolver only calls -pathForResource:ofType: and -fileExistsAtPath: on
# it. A .gitkeep keeps the directory tracked, since git cannot track empty dirs.
FRAMEWORKS=(ffmpegkit libavcodec libavdevice libavfilter libavformat libavutil libswresample libswscale)

info() { printf '\033[36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33mwarning:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# Primary source is modules/ffmpeg, which tools/fetch-ffmpegkit.sh builds and CI
# caches. Vendor/ is kept only as a legacy local-dev fallback for machines that
# have not run the source build; CI is expected to populate modules/ffmpeg.
resolve_modules() {
  local candidate
  for candidate in "$ROOT/modules/ffmpeg" "$ROOT/Vendor"; do
    [ -d "$candidate" ] || continue
    for f in "${FRAMEWORKS[@]}"; do
      [ -f "$candidate/$f.framework/$f" ] || continue 2
    done
    printf '%s' "$candidate"
    return 0
  done
  return 1
}

MODULES="$(resolve_modules || true)"

if [ -z "$MODULES" ]; then
  # Nothing to stage. Previously this only warned and shipped a build whose
  # every WebM->M4A conversion fails at runtime - that silent degradation is
  # the bug this script exists to prevent. If a build really must proceed
  # without ffmpeg, UYOUSTAGE_ALLOW_MISSING=1 keeps the old behaviour.
  if [ "${UYOUSTAGE_ALLOW_MISSING:-0}" = "1" ]; then
    warn "==============================================================="
    warn "no FFmpegKit frameworks in $ROOT/modules/ffmpeg or $ROOT/Vendor"
    warn "SKIPPING ffmpeg staging (UYOUSTAGE_ALLOW_MISSING=1) - the tweak"
    warn "cannot remux on its own at runtime."
    warn "==============================================================="
    exit 0
  fi
  die "no FFmpegKit frameworks in $ROOT/modules/ffmpeg or $ROOT/Vendor"
fi

BUNDLE="$(find "$STAGING" -type d -name "$BUNDLE_NAME" -print -quit 2>/dev/null || true)"

if [ -z "$BUNDLE" ]; then
  # If the bundle is not in the source tree yet (e.g. CI checkout where it was
  # never committed), create it so theos-jailed's EMBED_BUNDLES wildcard picks
  # it up during internal-package.
  [ -d "$STAGING" ] || die "bundle search root does not exist: $STAGING"
  mkdir -p "$STAGING/$BUNDLE_NAME"
  BUNDLE="$STAGING/$BUNDLE_NAME"
  warn "$BUNDLE_NAME not found under $STAGING - created $STAGING/$BUNDLE_NAME"
fi

[ -n "$BUNDLE" ] || die "could not locate or create $BUNDLE_NAME under $STAGING"

info "staging FFmpegKit into ${BUNDLE#"$STAGING"} (from ${MODULES#"$ROOT/"})"
for framework in "$MODULES"/*.framework; do
  [ -d "$framework" ] || continue
  name="$(basename "$framework")"
  rm -rf "${BUNDLE:?}/$name"
  cp -R "$framework" "$BUNDLE/$name"
  binary="$BUNDLE/$name/$name"
  if [ -f "$binary" ] && command -v ldid >/dev/null 2>&1; then
    ldid -S "$binary" 2>/dev/null || true
  fi
done

staged="$(find "$BUNDLE" -maxdepth 1 -type d -name '*.framework' | wc -l | tr -d ' ')"
info "staged $staged frameworks ($(du -sh "$MODULES" 2>/dev/null | cut -f1))"

missing=()
for f in "${FRAMEWORKS[@]}"; do
  [ -f "$BUNDLE/$f.framework/$f" ] || missing+=("$f")
done
if [ ${#missing[@]} -gt 0 ]; then
  die "incomplete ffmpeg stage, missing: ${missing[*]}"
fi
