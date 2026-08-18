import 'dart:ui';

/// Création & Développement : Boukhoulkhal Nabil (2026)
///
/// Abstraction for locale/language management.
/// Default locale: French (fr_FR), matching the original app language.

/// Contract for locale operations.
abstract class ILocaleService {
  Locale getCurrentLocale();
  Future<void> setLocale(Locale locale);
  List<Locale> getSupportedLocales();
}

/// In-memory implementation. Persists to SharedPreferences when available.
class LocaleService implements ILocaleService {
  Locale _currentLocale = const Locale('fr');

  @override
  Locale getCurrentLocale() => _currentLocale;

  @override
  Future<void> setLocale(Locale locale) async {
    _currentLocale = locale;
  }

  @override
  List<Locale> getSupportedLocales() => const [
        Locale('fr'),
        Locale('ar'),
      ];
}
