# .key — signing keys (NEVER commit the keys)

Holds signing keys for release builds (the Android upload keystore). Everything here is git-ignored
**except this README and `key.properties.example`** (see `.gitignore`).

## Android upload keystore (Flutter)

1. Generate a keystore (once) and place it here as `upload-keystore.jks`:

   ```bash
   keytool -genkeypair -v -keystore .key/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. One-time: wire Gradle to read `android/key.properties`. In `android/app/build.gradle.kts` (or
   `build.gradle`), before `android { ... }`, load the properties and add a `signingConfigs.release`
   that uses `storeFile/storePassword/keyAlias/keyPassword`, then set
   `buildTypes.release.signingConfig = signingConfigs.getByName("release")`.
   (See the Flutter docs: "Sign the app".) `android/key.properties` is git-ignored.

3. Provide passwords via environment variables (never commit them):

   - `ANDROID_KEYSTORE_PASSWORD` — the store password
   - `ANDROID_KEY_PASSWORD` — the key/alias password

4. Build a signed bundle with the run script (or the VS Code task **"build android (signed aab)"**):

   ```bash
   # Windows
   powershell -File scripts/build-android.ps1
   # macOS / Linux
   bash scripts/build-android.sh
   ```

   The script writes `android/key.properties` from your env vars and the keystore path, runs
   `flutter build appbundle`, and copies the signed `.aab` to `publish/android/`.

## Keep safe

- Back up the keystore securely — losing it means you can't update the app on Google Play.
- Store passwords in a secrets manager / CI secrets, never in committed files.
