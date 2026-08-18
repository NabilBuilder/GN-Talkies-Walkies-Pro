// Unit tests for FirestoreMaterielRepository.
//
// The app talks to Cloud Firestore through MethodChannel, which is not
// available on the Dart VM. We swap the platform interface for a lightweight
// in-memory fake (with read AND write support) and verify that the repository
// delegates add/update/delete/list operations correctly. A second test proves
// the IMaterielRepository contract is mockable with a plain in-memory fake.
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    as cfsi;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart' as fcp_test;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_materiel/di/service_locator.dart';
import 'package:gestion_materiel/models/materiel.dart';
import 'package:gestion_materiel/repositories/firestore_materiel_repository.dart';
import 'package:gestion_materiel/repositories/i_materiel_repository.dart';
import 'package:gestion_materiel/screens/materiel_list_screen.dart';

/// In-memory Firestore store: collectionPath -> documentId -> document data.
typedef _Store = Map<String, Map<String, Map<String, dynamic>>>;

class _FakeFirestore extends cfsi.FirebaseFirestorePlatform {
  _FakeFirestore(this._store)
      : super(appInstance: null, databaseChoice: '(default)');

  final _Store _store;

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
      _store.putIfAbsent(collectionPath, () => <String, Map<String, dynamic>>{}),
    );
  }

  @override
  cfsi.DocumentReferencePlatform doc(String path) {
    final parts = path.split('/');
    final collectionPath = parts.length >= 2 ? parts[parts.length - 2] : path;
    return _FakeDocumentReference(
      this,
      path,
      _store.putIfAbsent(
        collectionPath,
        () => <String, Map<String, dynamic>>{},
      ),
    );
  }
}

class _FakeCollectionReference extends cfsi.CollectionReferencePlatform {
  _FakeCollectionReference(super.firestore, super.path, this._docs);

  final Map<String, Map<String, dynamic>> _docs;

  // The app-facing Query.orderBy reads parameters['orderBy'] eagerly; provide
  // a non-null value so orderBy() calls do not crash.
  @override
  Map<String, dynamic> get parameters => {'orderBy': <List<dynamic>>[]};

  @override
  cfsi.QueryPlatform orderBy(Iterable<List<dynamic>> orders) => this;

  @override
  cfsi.DocumentReferencePlatform doc([String? path]) {
    final collectionPath = this.path;
    final documentId =
        path ?? DateTime.now().microsecondsSinceEpoch.toString();
    return _FakeDocumentReference(
      firestore,
      '$collectionPath/$documentId',
      _docs,
    );
  }

  @override
  Stream<cfsi.QuerySnapshotPlatform> snapshots({
    bool includeMetadataChanges = false,
    required cfsi.ListenSource listenSource,
  }) {
    return Stream.value(_snapshot());
  }

  cfsi.QuerySnapshotPlatform _snapshot() {
    final docs = _docs.entries.map((entry) {
      return cfsi.DocumentSnapshotPlatform(
        firestore,
        entry.key,
        entry.value,
        cfsi.InternalSnapshotMetadata(
          hasPendingWrites: false,
          isFromCache: true,
        ),
      );
    }).toList();

    return cfsi.QuerySnapshotPlatform(
      docs,
      const <cfsi.DocumentChangePlatform>[],
      cfsi.SnapshotMetadataPlatform(false, true),
    );
  }
}

class _FakeDocumentReference extends cfsi.DocumentReferencePlatform {
  _FakeDocumentReference(super.firestore, super.path, this._docs);

  final Map<String, Map<String, dynamic>> _docs;

  String get _id => path.split('/').last;

  @override
  Future<void> set(Map<String, dynamic> data, [cfsi.SetOptions? options]) async {
    _docs[_id] = Map<String, dynamic>.of(data);
  }

  @override
  Future<void> update(Map<cfsi.FieldPath, dynamic> data) async {
    final current = _docs.putIfAbsent(_id, () => <String, dynamic>{});
    data.forEach((fieldPath, value) {
      current[fieldPath.components.join('.')] = value;
    });
  }

  @override
  Future<void> delete() async {
    _docs.remove(_id);
  }
}

/// Plain in-memory fake proving the repository contract is mockable without
/// any Firestore dependency (what screens will use in widget tests).
class _InMemoryMaterielRepository implements IMaterielRepository {
  final Map<String, Materiel> _items = {};

  @override
  Stream<List<Materiel>> getMateriels() =>
      Stream.value(_items.values.toList());

  @override
  Future<void> addMateriel(Materiel materiel) async {
    _items[materiel.id] = materiel;
  }

  @override
  Future<void> updateMateriel(Materiel materiel) async {
    _items[materiel.id] = materiel;
  }

  @override
  Future<void> deleteMateriel(String id) async {
    _items.remove(id);
  }
}

Materiel _sampleMateriel(String id, {String? designation}) {
  final now = DateTime(2026, 8, 1, 9, 30);
  return Materiel(
    id: id,
    codeQR: 'QR-$id',
    designation: designation ?? 'Talkie Walkie Motorola GP340',
    numeroSerie: 'SN-$id',
    marque: 'Motorola',
    modele: 'GP340',
    etat: EtatMateriel.actif,
    siteActuel: 'Site Principal - Alger',
    marche: 'M2026-001',
    dateEnregistrement: now,
    derniereMiseAJour: now,
    enregistrePar: 'user-1',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // FirebaseFirestore.instance is a cached singleton, so the fake platform
  // must be installed ONCE (before the first access). Tests share the fake
  // and reset its in-memory store in setUp.
  late _Store store;

  setUpAll(() async {
    fcp_test.setupFirebaseCoreMocks();
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: '123',
        appId: '123',
        messagingSenderId: '123',
        projectId: '123',
      ),
    );
    store = <String, Map<String, Map<String, dynamic>>>{};
    cfsi.FirebaseFirestorePlatform.instance = _FakeFirestore(store);
    await setupServiceLocator();
  });

  tearDownAll(() async {
    await resetServiceLocator();
  });

  setUp(() {
    store.clear();
  });

  group('FirestoreMaterielRepository', () {
    test('addMateriel writes the document to the Materiels collection',
        () async {
      final repository = FirestoreMaterielRepository();
      final materiel = _sampleMateriel('mat-1');

      await repository.addMateriel(materiel);

      final stored = store['Materiels']!['mat-1']!;
      expect(store['Materiels'], hasLength(1));
      expect(stored['codeQR'], 'QR-mat-1');
      expect(stored['designation'], 'Talkie Walkie Motorola GP340');
      expect(stored['etat'], 'actif');
      expect(stored['siteActuel'], 'Site Principal - Alger');
    });

    test('updateMateriel updates an existing document', () async {
      final repository = FirestoreMaterielRepository();
      await repository.addMateriel(_sampleMateriel('mat-1'));

      final updated = _sampleMateriel(
        'mat-1',
        designation: 'Radio Hytera PD785',
      ).copyWith(etat: EtatMateriel.enPanne);
      await repository.updateMateriel(updated);

      final stored = store['Materiels']!['mat-1']!;
      expect(store['Materiels'], hasLength(1));
      expect(stored['designation'], 'Radio Hytera PD785');
      expect(stored['etat'], 'enPanne');
    });

    test('deleteMateriel removes the document', () async {
      final repository = FirestoreMaterielRepository();
      await repository.addMateriel(_sampleMateriel('mat-1'));
      await repository.addMateriel(_sampleMateriel('mat-2'));

      await repository.deleteMateriel('mat-1');

      expect(store['Materiels'], hasLength(1));
      expect(store['Materiels']!.containsKey('mat-1'), isFalse);
      expect(store['Materiels']!.containsKey('mat-2'), isTrue);
    });

    test('getMateriels streams materiels decoded from Firestore', () async {
      store['Materiels'] = {
        'mat-1': _sampleMateriel('mat-1').toMap(),
        'mat-2': _sampleMateriel('mat-2', designation: 'Kenwood TK-3201').toMap(),
      };

      final repository = FirestoreMaterielRepository();
      final materiels = await repository.getMateriels().first;

      expect(materiels, hasLength(2));
      expect(materiels.first.id, 'mat-1');
      expect(materiels.first.designation, 'Talkie Walkie Motorola GP340');
      expect(materiels.first.etat, EtatMateriel.actif);
      expect(materiels.last.designation, 'Kenwood TK-3201');
    });
  });

  testWidgets('MaterielListScreen loads materiels through the repository',
      (WidgetTester tester) async {
    store['Materiels'] = {
      'mat-1': _sampleMateriel('mat-1').toMap(),
      'mat-2': _sampleMateriel('mat-2', designation: 'Kenwood TK-3201').toMap(),
    };

    await tester.pumpWidget(const MaterialApp(home: MaterielListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Talkie Walkie Motorola GP340'), findsOneWidget);
    expect(find.text('Kenwood TK-3201'), findsOneWidget);
    expect(find.text('QR: QR-mat-1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('IMaterielRepository (mockable contract)', () {
    test('an in-memory fake can stand in for the real repository', () async {
      final IMaterielRepository repository = _InMemoryMaterielRepository();

      await repository.addMateriel(_sampleMateriel('mat-1'));
      await repository.addMateriel(_sampleMateriel('mat-2'));
      expect(await repository.getMateriels().first, hasLength(2));

      await repository.deleteMateriel('mat-1');
      final remaining = await repository.getMateriels().first;
      expect(remaining, hasLength(1));
      expect(remaining.single.id, 'mat-2');
    });
  });
}
