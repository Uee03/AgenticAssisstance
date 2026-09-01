#!/usr/bin/env bash
# Production-build the Angular app and zip the dist output into publish/.
# Angular emits to dist/<project>/browser. Override with DIST_PATH if needed.
set -euo pipefail

NAME="${NAME:-app}"
VERSION="${VERSION:-1.0.0}"
DIST_PATH="${DIST_PATH:-}"

npm run build

if [ -z "$DIST_PATH" ]; then
  DIST_PATH="$(find dist -maxdepth 1 -mindepth 1 -type d | head -n 1)"
  [ -d "$DIST_PATH/browser" ] && DIST_PATH="$DIST_PATH/browser"
fi

mkdir -p publish
ZIP="$(pwd)/publish/${NAME}-${VERSION}-web.zip"
rm -f "$ZIP"
( cd "$DIST_PATH" && zip -qr "$ZIP" . )
echo "Created publish/${NAME}-${VERSION}-web.zip"
