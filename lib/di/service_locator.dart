import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../platform_helper.dart';
import '../models/utilisateur.dart';
import '../models/historique_transfert.dart';
import '../repositories/i_historique_transfert_repository.dart';
import '../repositories/i_marche_repository.dart';
import '../repositories/i_materiel_repository.dart';
import '../repositories/i_site_repository.dart';
import '../repositories/i_utilisateur_repository.dart';
import '../repositories/inmemory_materiel_repository.dart';
import '../repositories/inmemory_site_repository.dart';
import '../repositories/inmemory_marche_repository.dart';
import '../services/i_sync_service.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';
import '../services/local_storage_service.dart';

// Deferred imports — only loaded on mobile (Firebase not available on desktop)
import '../repositories/firestore_historique_transfert_repository.dart'
    deferred as firestore_hist;
import '../repositories/firestore_marche_repository.dart'
    deferred as firestore_marche;
import '../repositories/firestore_materiel_repository.dart'
    deferred as firestore_materiel;
import '../repositories/firestore_site_repository.dart'
    deferred as firestore_site;
import '../repositories/firestore_utilisateur_repository.dart'
    deferred as firestore_utilisateur;
import '../services/sync_service.dart' deferred as firestore_sync;

/// Central service locator for dependency injection.
/// Création & Développement : Boukhoulkhal Nabil (2026)
final GetIt getIt = GetIt.instance;

/// Initializes Hive local storage. Must be called before [setupServiceLocator]
/// in production, or skipped / passed a pre-initialized instance in tests.
Future<ILocalStorageService> initLocalStorage([String? path]) async {
  final localStorage = HiveLocalStorageService();
  await localStorage.init(path);
  return localStorage;
}

/// Registers every repository interface → implementation.
///
/// On mobile: uses Firestore implementations (loaded deferred).
/// On desktop: uses in-memory implementations (Firebase not supported).
///
/// Must be called **once** in [main] before [runApp].
/// [localStorage] — pre-initialized local storage (or null to skip caching).
Future<void> setupServiceLocator({
  ILocalStorageService? localStorage,
}) async {
  debugPrint('ServiceLocator: Platform isDesktop=$isDesktop');

  // Register localStorage first (may be null for tests that don't need it)
  if (localStorage != null) {
    getIt.registerSingleton<ILocalStorageService>(localStorage);
  }

  // Register repositories based on platform
  if (isDesktop) {
    debugPrint('ServiceLocator: Registering InMemory repositories for desktop');
    // Desktop: Use in-memory repositories (Firebase not available)
    getIt
      ..registerLazySingleton<IMaterielRepository>(
        () => InMemoryMaterielRepository(),
      )
      ..registerLazySingleton<ISiteRepository>(
        () => InMemorySiteRepository(),
      )
      ..registerLazySingleton<IMarcheRepository>(
        () => InMemoryMarcheRepository(),
      )
      ..registerLazySingleton<IHistoriqueTransfertRepository>(
        () => InMemoryHistoriqueTransfertRepository(),
      )
      ..registerLazySingleton<IUtilisateurRepository>(
        () => InMemoryUtilisateurRepository(),
      )
      ..registerLazySingleton<ISyncService>(
        () => InMemorySyncService(),
      );
  } else {
    debugPrint('ServiceLocator: Loading Firestore repositories for mobile');
    // Mobile: Load deferred Firestore implementations
    await Future.wait([
      firestore_hist.loadLibrary(),
      firestore_marche.loadLibrary(),
      firestore_materiel.loadLibrary(),
      firestore_site.loadLibrary(),
      firestore_utilisateur.loadLibrary(),
      firestore_sync.loadLibrary(),
    ]);

    getIt
      ..registerLazySingleton<IMaterielRepository>(
        () => firestore_materiel.FirestoreMaterielRepository(
          localStorage: localStorage,
        ),
      )
      ..registerLazySingleton<ISiteRepository>(
        () => firestore_site.FirestoreSiteRepository(
          localStorage: localStorage,
        ),
      )
      ..registerLazySingleton<IMarcheRepository>(
        () => firestore_marche.FirestoreMarcheRepository(
          localStorage: localStorage,
        ),
      )
      ..registerLazySingleton<IHistoriqueTransfertRepository>(
        () => firestore_hist.FirestoreHistoriqueTransfertRepository(),
      )
      ..registerLazySingleton<IUtilisateurRepository>(
        () => firestore_utilisateur.FirestoreUtilisateurRepository(),
      )
      ..registerLazySingleton<ISyncService>(
        () => firestore_sync.FirestoreSyncService(
          localStorage: localStorage ?? _NullLocalStorage(),
        ),
      );
  }

  // Common services (platform-independent)
  getIt
    ..registerLazySingleton<ILocaleService>(
      () => LocaleService(),
    )
    ..registerLazySingleton<IThemeService>(
      () => ThemeService(),
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

// =============================================================================
// In-Memory implementations for Desktop
// =============================================================================

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
  Future<List<Map<String, dynamic>>> getMateriels({
    bool forceRefresh = false,
  }) =>
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
