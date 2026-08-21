import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart' as fcp_test;
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_materiel/di/service_locator.dart';
import 'package:gestion_materiel/platform_helper.dart';
import 'package:gestion_materiel/repositories/firestore_historique_transfert_repository.dart';
import 'package:gestion_materiel/repositories/firestore_marche_repository.dart';
import 'package:gestion_materiel/repositories/firestore_materiel_repository.dart';
import 'package:gestion_materiel/repositories/firestore_site_repository.dart';
import 'package:gestion_materiel/repositories/firestore_utilisateur_repository.dart';
import 'package:gestion_materiel/repositories/inmemory_materiel_repository.dart';
import 'package:gestion_materiel/repositories/inmemory_site_repository.dart';
import 'package:gestion_materiel/repositories/inmemory_marche_repository.dart';
import 'package:gestion_materiel/repositories/i_historique_transfert_repository.dart';
import 'package:gestion_materiel/repositories/i_marche_repository.dart';
import 'package:gestion_materiel/repositories/i_materiel_repository.dart';
import 'package:gestion_materiel/repositories/i_site_repository.dart';
import 'package:gestion_materiel/repositories/i_utilisateur_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Mock SharedPreferences for tests
    SharedPreferences.setMockInitialValues({});
    fcp_test.setupFirebaseCoreMocks();
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'test',
          appId: '1:000000000000:web:0000000000000000',
          messagingSenderId: '000000000000',
          projectId: 'test-project',
        ),
      );
    } on FirebaseException catch (_) {
      // Already initialized by another test in the same process — safe to ignore.
    }
    await setupServiceLocator();
  });

  tearDownAll(() async {
    await resetServiceLocator();
  });

  // Platform-aware tests
  test('IMaterielRepository resolves correctly for current platform', () {
    final repo = getIt<IMaterielRepository>();
    if (isDesktop) {
      expect(repo, isA<InMemoryMaterielRepository>());
    } else {
      expect(repo, isA<FirestoreMaterielRepository>());
    }
  });

  test('ISiteRepository resolves correctly for current platform', () {
    final repo = getIt<ISiteRepository>();
    if (isDesktop) {
      expect(repo, isA<InMemorySiteRepository>());
    } else {
      expect(repo, isA<FirestoreSiteRepository>());
    }
  });

  test('IMarcheRepository resolves correctly for current platform', () {
    final repo = getIt<IMarcheRepository>();
    if (isDesktop) {
      expect(repo, isA<InMemoryMarcheRepository>());
    } else {
      expect(repo, isA<FirestoreMarcheRepository>());
    }
  });

  test('IHistoriqueTransfertRepository resolves correctly for current platform',
      () {
    final repo = getIt<IHistoriqueTransfertRepository>();
    if (isDesktop) {
      // InMemory implementation is anonymous, just check it's not null
      expect(repo, isNotNull);
    } else {
      expect(repo, isA<FirestoreHistoriqueTransfertRepository>());
    }
  });

  test('IUtilisateurRepository resolves correctly for current platform', () {
    final repo = getIt<IUtilisateurRepository>();
    if (isDesktop) {
      // InMemory implementation is anonymous, just check it's not null
      expect(repo, isNotNull);
    } else {
      expect(repo, isA<FirestoreUtilisateurRepository>());
    }
  });

  test('Singleton: same instance returned on repeated lookups', () {
    final repo1 = getIt<IMaterielRepository>();
    final repo2 = getIt<IMaterielRepository>();
    expect(identical(repo1, repo2), isTrue);
  });
}
