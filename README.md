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

> ⚠️ If you ever commit a keystore by mistake, purge it from the entire Git
> history (e.g. `git filter-repo`/`git filter-branch`), **rotate the keystore**
> by generating a new one, and update the signing config accordingly.
