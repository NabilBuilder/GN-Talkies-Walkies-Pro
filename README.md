# Gardnet – Talkie Walkie Pro (gestion_materiel)

Flutter application for managing radio (talkie-walkie) equipment: Firebase
authentication, Cloud Firestore data, QR-code scanning, and PDF/Excel reports.

## Getting Started

- Flutter SDK: `>=3.12.2 <4.0.0`
- Run `flutter pub get`, then `flutter run`
- Quality gates: `flutter analyze` (must report no issues) and `flutter test` (all tests must pass)

## Android Release Signing (IMPORTANT)

The files `key.properties` and `release_keystore.jks` contain your signing
credentials and are **permanently excluded from Git** (see `.gitignore`).
They exist locally only — never commit or push them.

To set up signing on a new machine:

1. Copy the safe template to the real file:

   ```bash
   cp key.properties.example key.properties
   ```

2. Generate a **new** keystore if you do not have one (never reuse a keystore
   that has been exposed publicly — treat it as compromised and generate a new
   one so Play App Signing can be configured with fresh credentials):

   ```bash
   keytool -genkey -v -keystore release_keystore.jks \
           -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

3. Fill `key.properties` with your real passwords. The build reads it from
   `android/app/build.gradle.kts` (`rootProject.file("../key.properties")`).

> ⚠️ JDK 21 creates **PKCS12** keystores where the key password equals the
> store password (`-keypass` is ignored). In `key.properties` keep
> `keyPassword` equal to `storePassword`.

> ⚠️ If you ever commit a keystore by mistake, purge it from the entire Git
> history (e.g. `git filter-repo`/`git filter-branch`), **rotate the keystore**
> by generating a new one, and update the signing config accordingly.

### Current keystore status

- A **fresh upload keystore** (`release_keystore.jks`, alias `upload`) was
  generated locally on 2026-08-17.
- The previous keystore was tracked in Git and is therefore considered
  **compromised**. It is kept **only for migration** at
  `gn-security-backup-<date>/release_keystore_OLD.jks` (outside Git, with its
  original password).

## Play App Signing (Google Play)

Play App Signing lets Google hold the **app signing key** while you keep an
**upload key** for uploading release bundles. It is strongly recommended: even
if the upload key is ever leaked, it cannot be used to forge app updates.

### Case A — New app (no previous release in the store)

1. Build a signed release bundle:

   ```bash
   flutter build appbundle --release
   ```

2. In Google Play Console, create the app and go to **App signing**, choose to
   **create a new upload key** (or use your existing keystore), and upload the
   `.aab` from `build/app/outputs/bundle/release/`.
3. Google generates and securely stores the app signing key. Keep
   `release_keystore.jks` + `key.properties` safe and offline — they now hold
   your **upload key**.

### Case B — Existing app already distributed with the old (compromised) key

1. Enroll in Play App Signing and **upload the OLD keystore**
   (`release_keystore_OLD.jks` with its original password) as the current app
   signing key — Google adopts and holds it securely.
2. Then upload the **NEW** keystore (`release_keystore.jks`) as the **upload
   key**. From now on you sign uploads with the new key only.
3. If you cannot use the old key at all, request a key rotation via the Play
   Console form (App integrity → Request key upload/rotation).

> The leaked key becomes useless once Play App Signing is active: Google only
> accepts uploads signed by the current upload key, so the exposed key can no
> longer forge an update.

### Useful commands

- Inspect the local keystore (pass the password via a file to avoid typing it
  on the command line; see `-storepass:file`):

  ```bash
  keytool -list -v -keystore release_keystore.jks -storepass:file /path/to/password-file
  ```

  Copy the **SHA-256** fingerprint when Google Play Console asks for it.
- Verify the signature of a built APK:

  ```bash
  keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
  ```
