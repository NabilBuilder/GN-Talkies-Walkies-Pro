import 'package:flutter/material.dart';

/// Création & Développement : Boukhoulkhal Nabil (2026)
///
/// Defines the light and dark themes for the application.
/// Primary color: #1B5E20 (dark green) — consistent with the existing UI.

class AppTheme {
  AppTheme._();

  static const Color _primaryColor = Color(0xFF1B5E20);

  /// Light theme with bright background and green accent.
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorSchemeSeed: _primaryColor,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
  );

  /// Dark theme with deep background and green accent.
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorSchemeSeed: _primaryColor,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
  );
}
