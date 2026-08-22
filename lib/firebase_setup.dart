/// Mobile-only Firebase initialization module.
library;

/// This file is ONLY imported by main.dart on mobile platforms.
/// It imports firebase_options.dart (which imports firebase_core).
/// On desktop, main.dart does NOT import this file at all.
///
/// Création & Développement : Boukhoulkhal Nabil (2026)

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

/// Initializes all Firebase services for mobile platforms.
Future<void> setupFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase: initialized successfully');
  } catch (e) {
    debugPrint('Firebase: initialization failed: $e');
  }

  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: const AndroidDebugProvider(),
      providerApple: const AppleDebugProvider(),
    );
    debugPrint('Firebase App Check: initialized');
  } catch (e) {
    debugPrint('Firebase App Check: initialization failed: $e');
  }

  try {
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterError;
  } catch (e) {
    debugPrint('Firebase Crashlytics: initialization failed: $e');
  }
}
