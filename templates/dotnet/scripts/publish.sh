#!/usr/bin/env bash
# Build self-contained, single-file release binaries for each runtime and zip them into publish/.
# Override defaults with env vars, e.g.:
#   PROJECT=src/App/App.csproj VERSION=1.2.0 RIDS="linux-x64 osx-arm64" bash scripts/publish.sh
set -euo pipefail

PROJECT="${PROJECT:-src/App/App.csproj}"
VERSION="${VERSION:-1.0.0}"
IFS=' ' read -r -a RIDS <<< "${RIDS:-win-x64 linux-x64 osx-arm64}"
NAME="$(basename "$PROJECT" .csproj)"

mkdir -p publish
for rid in "${RIDS[@]}"; do
  echo "Publishing $rid ..."
  dotnet publish "$PROJECT" -c Release -r "$rid" --self-contained true \
    -p:PublishSingleFile=true -p:Version="$VERSION" -o "publish/$rid"
  ( cd "publish/$rid" && zip -qr "../${NAME}-${VERSION}-${rid}.zip" . )
  echo "Created publish/${NAME}-${VERSION}-${rid}.zip"
done
