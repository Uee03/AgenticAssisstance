# .key — signing keys (NEVER commit the keys)

This folder holds signing keys for release builds (e.g. the Android upload keystore for a .NET MAUI
app). Everything here is git-ignored **except this README** (see `.gitignore`:
`.key/*` + `!.key/README.md`).

## Android (MAUI) upload keystore

1. Generate a keystore (once) and place it here as `upload-keystore.jks`:

   ```bash
   keytool -genkeypair -v -keystore .key/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Provide the passwords via environment variables (never commit them):

   - `ANDROID_KEYSTORE_PASSWORD` — the store password
   - `ANDROID_KEY_PASSWORD` — the key/alias password

3. Build a signed bundle with the run script (or the VS Code task
   **"publish android (signed aab)"**):

   ```bash
   # Windows
   powershell -File scripts/build-android.ps1
   # macOS / Linux
   bash scripts/build-android.sh
   ```

The signed `.aab`/`.apk` is written to `publish/android/` (also git-ignored).

## Keep safe

- Back up the keystore securely — losing it means you can't update the app on Google Play.
- Store passwords in a secrets manager / CI secrets, not in files in this repo.
