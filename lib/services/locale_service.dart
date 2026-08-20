import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

/// Création & Développement : Boukhoulkhal Nabil (2026)
///
/// Abstraction for locale/language management.
/// Default locale: French (fr), matching the original app language.
/// Persists choice to SharedPreferences.

const String _kLocaleKey = 'app_locale';

/// Contract for locale operations.
abstract class ILocaleService {
  Locale getCurrentLocale();
  Future<void> setLocale(Locale locale);
  List<Locale> getSupportedLocales();
  Future<void> init();
}

/// LocaleService with SharedPreferences persistence.
class LocaleService implements ILocaleService {
  Locale _currentLocale = const Locale('fr');

  @override
  Locale getCurrentLocale() => _currentLocale;

  @override
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_kLocaleKey);
    if (savedLocale != null) {
      _currentLocale = Locale(savedLocale);
    }
  }

  @override
  Future<void> setLocale(Locale locale) async {
    _currentLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }

  @override
  List<Locale> getSupportedLocales() => const [
        Locale('fr'),
        Locale('ar'),
      ];
}
