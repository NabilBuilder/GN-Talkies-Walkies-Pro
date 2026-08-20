import 'package:get_it/get_it.dart';

import '../repositories/firestore_historique_transfert_repository.dart';
import '../repositories/firestore_marche_repository.dart';
import '../repositories/firestore_materiel_repository.dart';
import '../repositories/firestore_site_repository.dart';
import '../repositories/firestore_utilisateur_repository.dart';
import '../repositories/i_historique_transfert_repository.dart';
import '../repositories/i_marche_repository.dart';
import '../repositories/i_materiel_repository.dart';
import '../repositories/i_site_repository.dart';
import '../repositories/i_utilisateur_repository.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';

/// Central service locator for dependency injection.
///
/// All repositories are registered as singletons — the same instance is
/// returned for every lookup. This keeps the code decoupled from concrete
/// implementations while remaining simple (no generators, no code-gen).
/// Création & Développement : Boukhoulkhal Nabil (2026)
final GetIt getIt = GetIt.instance;

/// Initializes Hive local storage. Must be called before [setupServiceLocator]
/// in production, or skipped / passed a pre-initialized instance in tests.
///
/// [path] — optional directory path (used by tests to avoid path_provider).
Future<ILocalStorageService> initLocalStorage([String? path]) async {
  final localStorage = HiveLocalStorageService();
  await localStorage.init(path);
  return localStorage;
}

/// Registers every repository interface → Firestore implementation.
///
/// Must be called **once** in [main] before [runApp].
/// [localStorage] — pre-initialized local storage (or null to skip caching).
Future<void> setupServiceLocator({
  ILocalStorageService? localStorage,
}) async {
  // Register localStorage first (may be null for tests that don't need it)
  if (localStorage != null) {
    getIt.registerSingleton<ILocalStorageService>(localStorage);
  }

  getIt
    ..registerLazySingleton<IMaterielRepository>(
      () => FirestoreMaterielRepository(
        localStorage: localStorage,
      ),
    )
    ..registerLazySingleton<ISiteRepository>(
      () => FirestoreSiteRepository(
        localStorage: localStorage,
      ),
    )
    ..registerLazySingleton<IMarcheRepository>(
      () => FirestoreMarcheRepository(
        localStorage: localStorage,
      ),
    )
    ..registerLazySingleton<IHistoriqueTransfertRepository>(
      () => FirestoreHistoriqueTransfertRepository(),
    )
    ..registerLazySingleton<IUtilisateurRepository>(
      () => FirestoreUtilisateurRepository(),
    )
    ..registerLazySingleton<ILocaleService>(
      () => LocaleService(),
    )
    ..registerLazySingleton<IThemeService>(
      () => ThemeService(),
    )
    ..registerLazySingleton<ISyncService>(
      () => FirestoreSyncService(
        localStorage: localStorage ?? _NullLocalStorage(),
      ),
    );

  // Initialize persisted preferences
  await getIt<IThemeService>().init();
  await getIt<ILocaleService>().init();
}

/// Tears down all registrations — used only in tests.
Future<void> resetServiceLocator() async {
  await getIt.reset();
}

/// Null-object pattern: no-op local storage when Hive is not available.
class _NullLocalStorage implements ILocalStorageService {
  @override
  Future<void> init([String? path]) async {}
  @override
  Future<void> cacheMateriels(List<Map<String, dynamic>> materiels) async {}
  @override
  List<Map<String, dynamic>> getCachedMateriels() => [];
  @override
  Future<void> cacheSites(List<Map<String, dynamic>> sites) async {}
  @override
  List<Map<String, dynamic>> getCachedSites() => [];
  @override
  Future<void> cacheMarches(List<Map<String, dynamic>> marches) async {}
  @override
  List<Map<String, dynamic>> getCachedMarches() => [];
  @override
  Future<void> clearCache() async {}
}
