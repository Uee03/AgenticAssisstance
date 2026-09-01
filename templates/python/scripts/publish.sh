#!/usr/bin/env bash
# Build a standalone executable with PyInstaller into publish/<platform>/ and zip it.
# Cross-platform binaries must be built on each target OS (or via CI). Builds for the host OS.
set -euo pipefail

ENTRY="${ENTRY:-src/__project__/__main__.py}"
NAME="${NAME:-__project__}"
VERSION="${VERSION:-0.1.0}"

case "$(uname -s)" in
  Linux*)  PLATFORM="linux-x64" ;;
  Darwin*) PLATFORM="macos-arm64" ;;
  *)       PLATFORM="unknown" ;;
esac

OUT="publish/$PLATFORM"
mkdir -p "$OUT"

uv run pyinstaller --onefile --name "$NAME" --distpath "$OUT" --workpath "build/pyi" "$ENTRY"

( cd "$OUT" && zip -qr "../${NAME}-${VERSION}-${PLATFORM}.zip" . )
echo "Created publish/${NAME}-${VERSION}-${PLATFORM}.zip"
