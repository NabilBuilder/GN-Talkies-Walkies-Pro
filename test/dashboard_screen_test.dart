// Widget test for DashboardScreen using a fake Firestore platform interface.
//
// The real app talks to Cloud Firestore through MethodChannel, which is not
// available in widget tests. We swap the platform interface for a lightweight
// in-memory fake so the dashboard can be rendered with sample data.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    as cfsi;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart' as fcp_test;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_materiel/di/service_locator.dart';
import 'package:gestion_materiel/screens/dashboard_screen.dart';

/// In-memory [cfsi.FirebaseFirestorePlatform] that serves fixed documents for
/// the collections used by [DashboardScreen].
class _FakeFirestore extends cfsi.FirebaseFirestorePlatform {
  _FakeFirestore(this._collections)
      : super(appInstance: null, databaseChoice: '(default)');

  final Map<String, List<Map<String, dynamic>>> _collections;

  cfsi.Settings _settings = const cfsi.Settings(persistenceEnabled: true);

  @override
  cfsi.Settings get settings => _settings;

  @override
  set settings(cfsi.Settings settings) {
    _settings = settings;
  }

  @override
  cfsi.FirebaseFirestorePlatform delegateFor({
    required FirebaseApp app,
    required String databaseId,
  }) {
    return this;
  }

  @override
  cfsi.CollectionReferencePlatform collection(String collectionPath) {
    return _FakeCollectionReference(
      this,
      collectionPath,
      _collections[collectionPath] ?? const [],
    );
  }

  @override
  cfsi.DocumentReferencePlatform doc(String path) {
    return _FakeDocumentReference(this, path);
  }
}

/// Fake collection that replays its documents once as a query snapshot.
class _FakeCollectionReference extends cfsi.CollectionReferencePlatform {
  _FakeCollectionReference(super.firestore, super.path, this._docs);

  final List<Map<String, dynamic>> _docs;

  // The base implementation initializes parameters to an empty map, but the
  // app-facing Query.orderBy reads parameters['orderBy'] eagerly. Provide a
  // non-null value so orderBy() calls do not crash.
  @override
  Map<String, dynamic> get parameters => {'orderBy': <List<dynamic>>[]};

  @override
  cfsi.QueryPlatform orderBy(Iterable<List<dynamic>> orders) => this;

  @override
  Stream<cfsi.QuerySnapshotPlatform> snapshots({
    bool includeMetadataChanges = false,
    required cfsi.ListenSource listenSource,
  }) {
    final docs = _docs.asMap().entries.map((entry) {
      return cfsi.DocumentSnapshotPlatform(
        firestore,
        '${entry.key}_doc',
        entry.value,
        cfsi.InternalSnapshotMetadata(
          hasPendingWrites: false,
          isFromCache: true,
        ),
      );
    }).toList();

    return Stream.value(
      cfsi.QuerySnapshotPlatform(
        docs,
        const <cfsi.DocumentChangePlatform>[],
        cfsi.SnapshotMetadataPlatform(false, true),
      ),
    );
  }
}

/// Minimal fake document reference (all writes are unimplemented, none are
/// used while rendering the dashboard).
class _FakeDocumentReference extends cfsi.DocumentReferencePlatform {
  _FakeDocumentReference(super.firestore, super.path);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Mock the Firebase platform channels so no native Firebase app is
    // required when running widget tests on the Dart VM.
    fcp_test.setupFirebaseCoreMocks();
    // Values must match the ones returned by the mock (see MockFirebaseApp).
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: '123',
        appId: '123',
        messagingSenderId: '123',
        projectId: '123',
      ),
    );

    cfsi.FirebaseFirestorePlatform.instance = _FakeFirestore(_sampleData());
    await setupServiceLocator();
  });

  tearDownAll(() async {
    await resetServiceLocator();
  });

  testWidgets('Dashboard renders with sample data', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.pumpAndSettle();

    // Header + section titles.
    expect(find.text('Tableau de bord'), findsOneWidget);
    expect(find.text('Répartition par état'), findsOneWidget);
    expect(find.text('Matériels par site'), findsOneWidget);
    expect(find.text('Transferts récents'), findsOneWidget);

    // Stat cards.
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Actifs'), findsOneWidget);
    expect(find.text('En panne'), findsOneWidget);
    expect(find.text('Perdus'), findsOneWidget);
    expect(find.text('Sites'), findsOneWidget);
    expect(find.text('Marchés'), findsOneWidget);

    // Charts are built with the fl_chart 1.2.0 API and rendered without
    // throwing.
    expect(find.byType(PieChart), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

/// Sample documents mirroring the shape of the real Firestore collections.
Map<String, List<Map<String, dynamic>>> _sampleData() {
  final now = Timestamp.fromDate(DateTime(2026, 8, 10, 9, 30));

  return {
    'Materiels': [
      {
        'codeQR': 'TW-GARDNET-001',
        'designation': 'Talkie Walkie Motorola GP340',
        'numeroSerie': 'SN-MOT-001',
        'marque': 'Motorola',
        'modele': 'GP340',
        'etat': 'actif',
        'siteActuel': 'Site Principal - Alger',
        'marche': 'M2026-001',
        'imageUrl': '',
        'dateEnregistrement': now,
        'derniereMiseAJour': now,
        'enregistrePar': 'user-1',
      },
      {
        'codeQR': 'TW-GARDNET-002',
        'designation': 'Talkie Walkie Kenwood TK-3201',
        'numeroSerie': 'SN-KEN-001',
        'marque': 'Kenwood',
        'modele': 'TK-3201',
        'etat': 'actif',
        'siteActuel': 'Site Oran',
        'marche': 'M2026-002',
        'imageUrl': '',
        'dateEnregistrement': now,
        'derniereMiseAJour': now,
        'enregistrePar': 'user-1',
      },
      {
        'codeQR': 'TW-GARDNET-003',
        'designation': 'Radio Hytera PD785',
        'numeroSerie': 'SN-HYT-001',
        'marque': 'Hytera',
        'modele': 'PD785',
        'etat': 'enPanne',
        'siteActuel': 'Site Oran',
        'marche': 'M2026-002',
        'imageUrl': '',
        'dateEnregistrement': now,
        'derniereMiseAJour': now,
        'enregistrePar': 'user-2',
      },
      {
        'codeQR': 'TW-GARDNET-004',
        'designation': 'Talkie Walkie Icom IC-F4029',
        'numeroSerie': 'SN-ICM-001',
        'marque': 'Icom',
        'modele': 'IC-F4029',
        'etat': 'perdu',
        'siteActuel': 'Site Principal - Alger',
        'marche': 'M2026-001',
        'imageUrl': '',
        'dateEnregistrement': now,
        'derniereMiseAJour': now,
        'enregistrePar': 'user-2',
      },
    ],
    'Sites': [
      {
        'nom': 'Site Principal - Alger',
        'adresse': 'Zone Industrielle Rouiba',
        'ville': 'Alger',
        'responsable': 'M. Benali',
        'dateCreation': now,
      },
      {
        'nom': 'Site Oran',
        'adresse': 'Zone Industrielle Es-Sénia',
        'ville': 'Oran',
        'responsable': 'Mme. Mansouri',
        'dateCreation': now,
      },
    ],
    'Marches': [
      {
        'numero': 'M2026-001',
        'intitule': 'Maintenance Talkie Walkie - Site Est',
        'client': 'Sonelgaz',
        'dateDebut': now,
        'dateFin': null,
        'budget': 2500000.0,
      },
      {
        'numero': 'M2026-002',
        'intitule': 'Équipement de Communication - Site Ouest',
        'client': 'Entreprise des Télécommunications',
        'dateDebut': now,
        'dateFin': null,
        'budget': 1800000.0,
      },
    ],
    'Historique_Transferts': [
      {
        'materielId': 'doc_1',
        'materielDesignation': 'Talkie Walkie Kenwood TK-3201',
        'codeQR': 'TW-GARDNET-002',
        'siteOrigine': 'Site Principal - Alger',
        'siteDestination': 'Site Oran',
        'transferePar': 'user-1',
        'motif': 'Réaffectation',
        'dateTransfert': now,
        'confirme': true,
        'confirmePar': 'user-1',
        'dateConfirmation': now,
      },
    ],
  };
}
