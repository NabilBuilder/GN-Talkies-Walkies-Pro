import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'platform_helper.dart';
import 'di/service_locator.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'services/locale_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';

// Création & Développement : Boukhoulkhal Nabil (2026)

// Deferred import — ONLY loaded on mobile, never on desktop.
// This file imports firebase_core, firebase_options, etc.
import 'firebase_setup.dart' deferred as fb_setup;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // On desktop: suppress all Flutter errors to prevent red screen
  if (isDesktop) {
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('Desktop FlutterError (suppressed): ${details.exception}');
    };
    debugPrint('Desktop mode: Firebase will NOT be initialized');
  }

  // Firebase initialization — ONLY on mobile platforms (deferred loading)
  if (isMobile) {
    try {
      await fb_setup.loadLibrary();
      await fb_setup.setupFirebase();
    } catch (e) {
      debugPrint('Firebase setup failed: $e');
    }
  }

  // Initialize local storage and service locator
  try {
    if (isMobile) {
      final localStorage = await initLocalStorage();
      await setupServiceLocator(localStorage: localStorage);
    } else {
      await setupServiceLocator();
    }
    debugPrint(
        'ServiceLocator initialized for ${isDesktop ? "desktop" : "mobile"}');
  } catch (e) {
    debugPrint('Service locator initialization failed: $e');
    await setupServiceLocator();
  }

  // Run app with error handling
  runZonedGuarded<Future<void>>(
    () async {
      runApp(const GestionMaterielApp());
    },
    (error, stackTrace) {
      debugPrint('Zone error: $error');
    },
  );
}

class GestionMaterielApp extends StatelessWidget {
  const GestionMaterielApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = getIt<IThemeService>();
    final localeService = getIt<ILocaleService>();

    return MaterialApp(
      title: 'GN Talkies-Walkies Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.getThemeMode(),
      locale: localeService.getCurrentLocale(),
      supportedLocales: localeService.getSupportedLocales(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
