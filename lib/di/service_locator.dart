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
final GetIt getIt = GetIt.instance;

/// Registers every repository interface → Firestore implementation.
///
/// Must be called **once** in [main] before [runApp].
Future<void> setupServiceLocator() async {
  getIt
    ..registerLazySingleton<IMaterielRepository>(
      () => FirestoreMaterielRepository(),
    )
    ..registerLazySingleton<ISiteRepository>(
      () => FirestoreSiteRepository(),
    )
    ..registerLazySingleton<IMarcheRepository>(
      () => FirestoreMarcheRepository(),
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
    ..registerLazySingleton<ILocalStorageService>(
      () => HiveLocalStorageService(),
    )
    ..registerLazySingleton<ISyncService>(
      () => FirestoreSyncService(
        localStorage: getIt<ILocalStorageService>(),
      ),
    );
}

/// Tears down all registrations — used only in tests.
Future<void> resetServiceLocator() async {
  await getIt.reset();
}
