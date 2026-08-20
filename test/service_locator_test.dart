import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart' as fcp_test;
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_materiel/di/service_locator.dart';
import 'package:gestion_materiel/repositories/firestore_historique_transfert_repository.dart';
import 'package:gestion_materiel/repositories/firestore_marche_repository.dart';
import 'package:gestion_materiel/repositories/firestore_materiel_repository.dart';
import 'package:gestion_materiel/repositories/firestore_site_repository.dart';
import 'package:gestion_materiel/repositories/firestore_utilisateur_repository.dart';
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

  test('IMaterielRepository resolves to FirestoreMaterielRepository', () {
    final repo = getIt<IMaterielRepository>();
    expect(repo, isA<FirestoreMaterielRepository>());
  });

  test('ISiteRepository resolves to FirestoreSiteRepository', () {
    final repo = getIt<ISiteRepository>();
    expect(repo, isA<FirestoreSiteRepository>());
  });

  test('IMarcheRepository resolves to FirestoreMarcheRepository', () {
    final repo = getIt<IMarcheRepository>();
    expect(repo, isA<FirestoreMarcheRepository>());
  });

  test(
      'IHistoriqueTransfertRepository resolves to FirestoreHistoriqueTransfertRepository',
      () {
    final repo = getIt<IHistoriqueTransfertRepository>();
    expect(repo, isA<FirestoreHistoriqueTransfertRepository>());
  });

  test('IUtilisateurRepository resolves to FirestoreUtilisateurRepository',
      () {
    final repo = getIt<IUtilisateurRepository>();
    expect(repo, isA<FirestoreUtilisateurRepository>());
  });

  test('Singleton: same instance returned on repeated lookups', () {
    final repo1 = getIt<IMaterielRepository>();
    final repo2 = getIt<IMaterielRepository>();
    expect(identical(repo1, repo2), isTrue);
  });
}
