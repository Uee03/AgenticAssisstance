#!/usr/bin/env bash
# Build a Flutter target and zip it into publish/<target>/.
# TARGET is one of: web, linux, apk    e.g. TARGET=web VERSION=1.2.0 NAME=myapp bash scripts/publish.sh
set -euo pipefail

TARGET="${TARGET:-web}"
VERSION="${VERSION:-1.0.0}"
NAME="${NAME:-app}"

case "$TARGET" in
  web)   flutter build web --release;   SRC="build/web" ;;
  linux) flutter build linux --release; SRC="build/linux/x64/release/bundle" ;;
  apk)   flutter build apk --release;   SRC="build/app/outputs/flutter-apk" ;;
  *) echo "Unknown target: $TARGET (use web|linux|apk)"; exit 1 ;;
esac

OUT="publish/$TARGET"
mkdir -p "$OUT"
cp -R "$SRC/." "$OUT/"
( cd "$OUT" && zip -qr "../${NAME}-${VERSION}-${TARGET}.zip" . )
echo "Created publish/${NAME}-${VERSION}-${TARGET}.zip"
