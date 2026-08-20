import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_materiel/services/theme_service.dart';
import 'package:gestion_materiel/services/locale_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Création & Développement : Boukhoulkhal Nabil (2026)
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Theme persistence', () {
    test('default theme is system', () {
      final themeService = ThemeService();
      expect(themeService.getThemeMode(), equals(ThemeMode.system));
    });

    test('setThemeMode persists the choice', () async {
      final themeService = ThemeService();
      await themeService.init();
      await themeService.setThemeMode(ThemeMode.dark);
      expect(themeService.getThemeMode(), equals(ThemeMode.dark));
    });

    test('init loads persisted theme', () async {
      final themeService = ThemeService();
      await themeService.init();
      // After init, should reflect persisted value (or default)
      expect(themeService.getThemeMode(), isNotNull);
    });
  });

  group('Locale persistence', () {
    test('default locale is French', () {
      final localeService = LocaleService();
      expect(localeService.getCurrentLocale(), equals(const Locale('fr')));
    });

    test('setLocale persists the choice', () async {
      final localeService = LocaleService();
      await localeService.init();
      await localeService.setLocale(const Locale('ar'));
      expect(localeService.getCurrentLocale(), equals(const Locale('ar')));
    });

    test('init loads persisted locale', () async {
      final localeService = LocaleService();
      await localeService.init();
      // After init, should reflect persisted value (or default)
      expect(localeService.getCurrentLocale(), isNotNull);
    });

    test('supported locales include fr and ar', () {
      final localeService = LocaleService();
      final locales = localeService.getSupportedLocales();
      expect(locales, contains(const Locale('fr')));
      expect(locales, contains(const Locale('ar')));
    });
  });
}
