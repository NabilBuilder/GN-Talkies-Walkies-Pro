// Unit tests for FirestoreHistoriqueTransfertRepository.
//
// Tests focus on ATOMICITY of the batch transfer operation:
// - Success path: both materiel update and history creation succeed
// - Failure path: if commit fails, no partial state persists
// Uses a Fake Firestore with full batch support (read + write + batch).
import 'dart:async';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    as cfsi;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart' as fcp_test;
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_materiel/models/historique_transfert.dart';
import 'package:gestion_materiel/models/materiel.dart';
import 'package:gestion_materiel/repositories/firestore_historique_transfert_repository.dart';
import 'package:gestion_materiel/repositories/i_historique_transfert_repository.dart';

/// In-memory Firestore store: collectionPath -> documentId -> document data.
typedef _Store = Map<String, Map<String, Map<String, dynamic>>>;

// ---------------------------------------------------------------------------
// Fake Firestore with batch support
// ---------------------------------------------------------------------------

class _FakeFirestore extends cfsi.FirebaseFirestorePlatform {
  _FakeFirestore(this._store)
      : super(appInstance: null, databaseChoice: '(default)');

  final _Store _store;
  bool failCommit = false;

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
      _store.putIfAbsent(
          collectionPath, () => <String, Map<String, dynamic>>{}),
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

  @override
  cfsi.WriteBatchPlatform batch() {
    return _FakeBatch(_store, failCommit: failCommit);
  }

  void reset({bool failCommit = false}) {
    this.failCommit = failCommit;
  }
}

class _FakeCollectionReference extends cfsi.CollectionReferencePlatform {
  _FakeCollectionReference(super.firestore, super.path, this._docs);

  final Map<String, Map<String, dynamic>> _docs;

  @override
  Map<String, dynamic> get parameters => {'orderBy': <List<dynamic>>[]};

  @override
  cfsi.QueryPlatform orderBy(Iterable<List<dynamic>> orders) => this;

  @override
  cfsi.DocumentReferencePlatform doc([String? path]) {
    final collectionPath = this.path;
    final documentId =
        path ?? DateTime.now().microsecondsSinceEpoch.toString();
    return _FakeDocumentReference(firestore, '$collectionPath/$documentId', _docs);
  }

  @override
  Stream<cfsi.QuerySnapshotPlatform> snapshots({
    bool includeMetadataChanges = false,
    required cfsi.ListenSource listenSource,
  }) {
    return Stream.value(_snapshot());
  }

  @override
  Future<cfsi.QuerySnapshotPlatform> get([cfsi.GetOptions? options]) async {
    return _snapshot();
  }

  cfsi.QuerySnapshotPlatform _snapshot() {
    final docs = _docs.entries.map((entry) {
      return cfsi.DocumentSnapshotPlatform(
        firestore,
        entry.key,
        entry.value,
        cfsi.InternalSnapshotMetadata(hasPendingWrites: false, isFromCache: true),
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

/// Fake write batch that collects operations and applies them atomically.
///
/// Operations are buffered in [_stagedOps] and only committed to [_store]
/// when [commit] is called. If [_failCommit] is true, [commit] throws
/// without applying any changes — proving atomicity.
class _FakeBatch extends cfsi.WriteBatchPlatform {
  _FakeBatch(this._store, {this._failCommit = false});

  final _Store _store;
  final bool _failCommit;
  final List<_BatchOp> _stagedOps = [];

  @override
  Future<void> commit() async {
    if (_failCommit) {
      throw Exception('Simulated batch commit failure');
    }
    // Apply all staged operations atomically.
    for (final op in _stagedOps) {
      op.apply(_store);
    }
    _stagedOps.clear();
  }

  @override
  void set(String documentPath, Map<String, dynamic> data,
      [cfsi.SetOptions? options]) {
    _stagedOps.add(_SetOp(documentPath, data));
  }

  @override
  void update(String documentPath, Map<cfsi.FieldPath, dynamic> data) {
    _stagedOps.add(_UpdateOp(documentPath, data));
  }

  @override
  void delete(String documentPath) {
    _stagedOps.add(_DeleteOp(documentPath));
  }
}

/// A staged batch operation.
abstract class _BatchOp {
  void apply(_Store store);
}

class _SetOp extends _BatchOp {
  _SetOp(this.path, this.data);
  final String path;
  final Map<String, dynamic> data;

  @override
  void apply(_Store store) {
    final parts = path.split('/');
    final collectionPath = parts.length >= 2
        ? parts[parts.length - 2]
        : path;
    final docId = parts.last;
    final docs = store.putIfAbsent(
        collectionPath, () => <String, Map<String, dynamic>>{});
    docs[docId] = Map<String, dynamic>.of(data);
  }
}

class _UpdateOp extends _BatchOp {
  _UpdateOp(this.path, this.data);
  final String path;
  final Map<cfsi.FieldPath, dynamic> data;

  @override
  void apply(_Store store) {
    final parts = path.split('/');
    final collectionPath = parts.length >= 2
        ? parts[parts.length - 2]
        : path;
    final docId = parts.last;
    final docs = store.putIfAbsent(
        collectionPath, () => <String, Map<String, dynamic>>{});
    final current = docs.putIfAbsent(docId, () => <String, dynamic>{});
    data.forEach((fieldPath, value) {
      current[fieldPath.components.join('.')] = value;
    });
  }
}

class _DeleteOp extends _BatchOp {
  _DeleteOp(this.path);
  final String path;

  @override
  void apply(_Store store) {
    final parts = path.split('/');
    final collectionPath = parts.length >= 2
        ? parts[parts.length - 2]
        : path;
    final docId = parts.last;
    store[collectionPath]?.remove(docId);
  }
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

Materiel _sampleMateriel(String id) {
  final now = DateTime(2026, 8, 1, 9, 30);
  return Materiel(
    id: id,
    codeQR: 'QR-$id',
    designation: 'Talkie Walkie Motorola GP340',
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

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Store store;
  late _FakeFirestore fakeFirestore;

  setUpAll(() async {
    fcp_test.setupFirebaseCoreMocks();
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: '123',
        appId: '123',
        messagingSenderId: '123',
        projectId: '123',
      ),
    );
    store = <String, Map<String, Map<String, dynamic>>>{};
    fakeFirestore = _FakeFirestore(store);
    cfsi.FirebaseFirestorePlatform.instance = fakeFirestore;
  });

  setUp(() {
    store.clear();
    fakeFirestore.reset();
  });

  // ---- getHistory ----

  group('getHistory', () {
    test('streams transfer records decoded from Firestore', () async {
      final now = DateTime(2026, 8, 15);
      store['Historique_Transferts'] = {
        't-1': HistoriqueTransfert(
          id: 't-1',
          materielId: 'mat-1',
          materielDesignation: 'Radio GP340',
          codeQR: 'QR-1',
          siteOrigine: 'Alger',
          siteDestination: 'Oran',
          transferePar: 'user-1',
          motif: 'Réaffectation',
          dateTransfert: now,
        ).toMap(),
      };

      final repository = FirestoreHistoriqueTransfertRepository();
      final history = await repository.getHistory().first;

      expect(history, hasLength(1));
      expect(history.first.id, 't-1');
      expect(history.first.siteOrigine, 'Alger');
      expect(history.first.siteDestination, 'Oran');
    });

    test('returns empty stream when no transfers exist', () async {
      final repository = FirestoreHistoriqueTransfertRepository();
      final history = await repository.getHistory().first;
      expect(history, isEmpty);
    });
  });

  // ---- executeTransfer: SUCCESS ----

  group('executeTransfer (atomicity — success)', () {
    test('commits both materiel update and history creation', () async {
      // Seed a materiel document.
      final materiel = _sampleMateriel('mat-1');
      store['Materiels'] = {'mat-1': materiel.toMap()};

      final repository = FirestoreHistoriqueTransfertRepository();

      await repository.executeTransfer(
        materielId: 'mat-1',
        materielDesignation: materiel.designation,
        codeQR: materiel.codeQR,
        siteOrigine: materiel.siteActuel,
        siteDestination: 'Site Oran',
        transferePar: 'user-1',
        motif: 'Réaffectation',
      );

      // Materiel site updated.
      expect(store['Materiels']!['mat-1']!['siteActuel'], 'Site Oran');
      expect(store['Materiels']!['mat-1']!.containsKey('derniereMiseAJour'),
          isTrue);

      // History record created.
      expect(store['Historique_Transferts'], hasLength(1));
      final record = store['Historique_Transferts']!.values.first;
      expect(record['materielId'], 'mat-1');
      expect(record['siteOrigine'], 'Site Principal - Alger');
      expect(record['siteDestination'], 'Site Oran');
      expect(record['motif'], 'Réaffectation');
      expect(record['confirme'], false);
    });

    test('transfer record has correct fields', () async {
      final materiel = _sampleMateriel('mat-1');
      store['Materiels'] = {'mat-1': materiel.toMap()};

      final repository = FirestoreHistoriqueTransfertRepository();

      await repository.executeTransfer(
        materielId: 'mat-1',
        materielDesignation: 'Radio Hytera PD785',
        codeQR: 'QR-H785',
        siteOrigine: 'Alger',
        siteDestination: 'Constantine',
        transferePar: 'admin',
        motif: 'Maintenance',
      );

      final record = store['Historique_Transferts']!.values.first;
      expect(record['materielDesignation'], 'Radio Hytera PD785');
      expect(record['codeQR'], 'QR-H785');
      expect(record['transferePar'], 'admin');
      expect(record['dateTransfert'], isNotNull);
    });
  });

  // ---- executeTransfer: FAILURE (atomicity proof) ----

  group('executeTransfer (atomicity — failure)', () {
    test('no partial state persists when batch commit fails', () async {
      // Seed a materiel document.
      final materiel = _sampleMateriel('mat-1');
      store['Materiels'] = {'mat-1': materiel.toMap()};

      // Toggle the shared fake to fail on commit.
      fakeFirestore.reset(failCommit: true);

      final repository = FirestoreHistoriqueTransfertRepository();

      // The transfer should throw.
      expect(
        () => repository.executeTransfer(
          materielId: 'mat-1',
          materielDesignation: materiel.designation,
          codeQR: materiel.codeQR,
          siteOrigine: materiel.siteActuel,
          siteDestination: 'Site Oran',
          transferePar: 'user-1',
          motif: 'Réaffectation',
        ),
        throwsA(isA<Exception>()),
      );

      // Materiel site must NOT have changed (no partial write).
      expect(store['Materiels']!['mat-1']!['siteActuel'],
          'Site Principal - Alger');

      // No transfer record must have been created (batch never committed).
      expect(store['Historique_Transferts'] ?? {}, isEmpty);
    });

    test('multiple documents remain unchanged after commit failure',
        () async {
      store['Materiels'] = {
        'mat-1': _sampleMateriel('mat-1').toMap(),
        'mat-2': _sampleMateriel('mat-2').toMap(),
      };

      fakeFirestore.reset(failCommit: true);

      final repository = FirestoreHistoriqueTransfertRepository();

      expect(
        () => repository.executeTransfer(
          materielId: 'mat-1',
          materielDesignation: 'Radio',
          codeQR: 'QR-1',
          siteOrigine: 'Alger',
          siteDestination: 'Oran',
          transferePar: 'user-1',
          motif: 'Test',
        ),
        throwsA(isA<Exception>()),
      );

      // Both materiels untouched.
      expect(store['Materiels']!['mat-1']!['siteActuel'],
          'Site Principal - Alger');
      expect(store['Materiels']!['mat-2']!['siteActuel'],
          'Site Principal - Alger');
      expect(store['Historique_Transferts'] ?? {}, isEmpty);
    });
  });

  // ---- Interface substitutability ----

  group('IHistoriqueTransfertRepository (mockable contract)', () {
    test('an in-memory fake can stand in for the real repository', () async {
      final fake = _InMemoryTransfertRepository();

      await fake.executeTransfer(
        materielId: 'mat-1',
        materielDesignation: 'Radio',
        codeQR: 'QR-1',
        siteOrigine: 'Alger',
        siteDestination: 'Oran',
        transferePar: 'user-1',
        motif: 'Test',
      );

      final IHistoriqueTransfertRepository repo = fake;
      final history = await repo.getHistory().first;
      expect(history, hasLength(1));
      expect(history.first.siteDestination, 'Oran');
    });
  });
}

// ---------------------------------------------------------------------------
// In-memory fake for interface substitutability test
// ---------------------------------------------------------------------------

class _InMemoryTransfertRepository implements IHistoriqueTransfertRepository {
  final List<HistoriqueTransfert> _history = [];

  @override
  Stream<List<HistoriqueTransfert>> getHistory() =>
      Stream.value(List.unmodifiable(_history));

  @override
  Future<void> executeTransfer({
    required String materielId,
    required String materielDesignation,
    required String codeQR,
    required String siteOrigine,
    required String siteDestination,
    required String transferePar,
    required String motif,
  }) async {
    _history.add(HistoriqueTransfert(
      id: 'fake-${_history.length}',
      materielId: materielId,
      materielDesignation: materielDesignation,
      codeQR: codeQR,
      siteOrigine: siteOrigine,
      siteDestination: siteDestination,
      transferePar: transferePar,
      motif: motif,
      dateTransfert: DateTime.now(),
    ));
  }
}
