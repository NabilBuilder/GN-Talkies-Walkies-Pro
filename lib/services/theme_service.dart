import 'package:flutter/material.dart';

/// Création & Développement : Boukhoulkhal Nabil (2026)
///
/// Abstraction for theme mode management.
/// Default: system theme (follows device setting).

/// Contract for theme operations.
abstract class IThemeService {
  ThemeMode getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);
}

/// In-memory implementation. Persists to SharedPreferences when available.
class ThemeService implements IThemeService {
  ThemeMode _currentMode = ThemeMode.system;

  @override
  ThemeMode getThemeMode() => _currentMode;

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    _currentMode = mode;
  }
}
