import 'package:get_it/get_it.dart';
import '../platform_helper.dart';

import '../models/utilisateur.dart';
import '../models/historique_transfert.dart';
import '../repositories/firestore_historique_transfert_repository.dart';
import '../repositories/firestore_marche_repository.dart';
import '../repositories/firestore_materiel_repository.dart';
import '../repositories/firestore_site_repository.dart';
import '../repositories/firestore_utilisateur_repository.dart';
import '../repositories/inmemory_materiel_repository.dart';
import '../repositories/inmemory_site_repository.dart';
import '../repositories/inmemory_marche_repository.dart';
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

/// Registers every repository interface → implementation.
///
/// On mobile: uses Firestore implementations.
/// On desktop: uses in-memory implementations (Firebase not supported).
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

  // Register repositories based on platform
  if (isDesktop) {
    // Desktop: Use in-memory repositories (Firebase not available)
    final inMemoryMaterielRepo = InMemoryMaterielRepository();
    final inMemorySiteRepo = InMemorySiteRepository();
    final inMemoryMarcheRepo = InMemoryMarcheRepository();

    getIt
      ..registerLazySingleton<IMaterielRepository>(
        () => inMemoryMaterielRepo,
      )
      ..registerLazySingleton<ISiteRepository>(
        () => inMemorySiteRepo,
      )
      ..registerLazySingleton<IMarcheRepository>(
        () => inMemoryMarcheRepo,
      )
      ..registerLazySingleton<IHistoriqueTransfertRepository>(
        () => InMemoryHistoriqueTransfertRepository(),
      )
      ..registerLazySingleton<IUtilisateurRepository>(
        () => InMemoryUtilisateurRepository(),
      );
  } else {
    // Mobile: Use Firestore repositories
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
      );
  }

  // Common services (platform-independent)
  getIt
    ..registerLazySingleton<ILocaleService>(
      () => LocaleService(),
    )
    ..registerLazySingleton<IThemeService>(
      () => ThemeService(),
    )
    ..registerLazySingleton<ISyncService>(
      () => isDesktop
          ? InMemorySyncService()
          : FirestoreSyncService(
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

// ============================================================================
// In-Memory implementations for Desktop
// ============================================================================

class InMemoryHistoriqueTransfertRepository
    implements IHistoriqueTransfertRepository {
  @override
  Future<void> executeTransfer({
    required String materielId,
    required String materielDesignation,
    required String codeQR,
    required String siteOrigine,
    required String siteDestination,
    required String transferePar,
    required String motif,
  }) async {}
  @override
  Stream<List<HistoriqueTransfert>> getHistory() => Stream.value([]);
}

class InMemoryUtilisateurRepository implements IUtilisateurRepository {
  @override
  Future<Utilisateur?> getById(String id) async => null;
  @override
  Future<void> create(Utilisateur user) async {}
  @override
  Future<void> update(Utilisateur user) async {}
}

class InMemorySyncService implements ISyncService {
  @override
  Future<bool> syncAll() async => true;
  @override
  Future<List<Map<String, dynamic>>> getMateriels({bool forceRefresh = false}) =>
      Future.value([]);
  @override
  Future<List<Map<String, dynamic>>> getSites({bool forceRefresh = false}) =>
      Future.value([]);
  @override
  Future<List<Map<String, dynamic>>> getMarches({bool forceRefresh = false}) =>
      Future.value([]);
  @override
  Future<void> initializeDemoDataIfNeeded() async {}
}
