#!/usr/bin/env bash
# Build a signed Android App Bundle (Flutter) into publish/android/.
# Passwords come from environment variables — NEVER hardcode them:
#   ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_PASSWORD
# Keystore lives at .key/upload-keystore.jks (see .key/README.md). Writes a git-ignored
# android/key.properties, then runs `flutter build appbundle`.
# One-time: wire android/app/build.gradle(.kts) to read key.properties (snippet in .key/README.md).
set -euo pipefail

KEY_ALIAS="${1:-upload}"
VERSION="${2:-1.0.0}"

: "${ANDROID_KEYSTORE_PASSWORD:?Set env var ANDROID_KEYSTORE_PASSWORD first.}"
: "${ANDROID_KEY_PASSWORD:?Set env var ANDROID_KEY_PASSWORD first.}"
[ -f ".key/upload-keystore.jks" ] || { echo "Keystore not found at .key/upload-keystore.jks (see .key/README.md)"; exit 1; }

STORE_FILE="$(cd .key && pwd)/upload-keystore.jks"
cat > android/key.properties <<EOF
storePassword=${ANDROID_KEYSTORE_PASSWORD}
keyPassword=${ANDROID_KEY_PASSWORD}
keyAlias=${KEY_ALIAS}
storeFile=${STORE_FILE}
EOF

flutter build appbundle --release --build-name="$VERSION"

OUT="publish/android"
mkdir -p "$OUT"
cp build/app/outputs/bundle/release/app-release.aab "$OUT/app-${VERSION}-release.aab"
echo "Signed AAB written to $OUT"
