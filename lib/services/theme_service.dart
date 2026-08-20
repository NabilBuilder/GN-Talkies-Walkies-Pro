import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Création & Développement : Boukhoulkhal Nabil (2026)
///
/// Abstraction for theme mode management.
/// Default: system theme (follows device setting).
/// Persists choice to SharedPreferences.

const String _kThemeModeKey = 'theme_mode';

/// Contract for theme operations.
abstract class IThemeService {
  ThemeMode getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);
  Future<void> init();
}

/// ThemeService with SharedPreferences persistence.
class ThemeService implements IThemeService {
  ThemeMode _currentMode = ThemeMode.system;

  @override
  ThemeMode getThemeMode() => _currentMode;

  @override
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_kThemeModeKey);
    if (savedMode != null) {
      _currentMode = ThemeMode.values.firstWhere(
        (m) => m.name == savedMode,
        orElse: () => ThemeMode.system,
      );
    }
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    _currentMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, mode.name);
  }
}
