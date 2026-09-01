#!/usr/bin/env bash
# Build a signed Android App Bundle (.NET MAUI) into publish/android/.
# Keystore passwords come from environment variables — NEVER hardcode them:
#   ANDROID_KEYSTORE_PASSWORD  (store password)
#   ANDROID_KEY_PASSWORD       (key/alias password)
# Place your keystore at .key/upload-keystore.jks (see .key/README.md). MAUI apps only.
set -euo pipefail

PROJECT="${1:-src/App/App.csproj}"
VERSION="${2:-1.0.0}"
KEYSTORE="${3:-.key/upload-keystore.jks}"
KEY_ALIAS="${4:-upload}"

: "${ANDROID_KEYSTORE_PASSWORD:?Set env var ANDROID_KEYSTORE_PASSWORD first.}"
: "${ANDROID_KEY_PASSWORD:?Set env var ANDROID_KEY_PASSWORD first.}"
[ -f "$KEYSTORE" ] || { echo "Keystore not found at $KEYSTORE (see .key/README.md)"; exit 1; }

OUT="publish/android"
mkdir -p "$OUT"

dotnet publish "$PROJECT" -f net10.0-android -c Release \
  -p:Version="$VERSION" \
  -p:AndroidKeyStore=true \
  -p:AndroidSigningKeyStore="$KEYSTORE" \
  -p:AndroidSigningKeyAlias="$KEY_ALIAS" \
  -p:AndroidSigningStorePass="$ANDROID_KEYSTORE_PASSWORD" \
  -p:AndroidSigningKeyPass="$ANDROID_KEY_PASSWORD" \
  -o "$OUT"
echo "Signed AAB/APK written to $OUT"
