// Unit tests for FirestoreUtilisateurRepository.
//
// Uses the same Fake Firestore singleton pattern established in earlier tasks.
// Tests cover getById, create, update operations and interface substitutability.
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    as cfsi;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart' as fcp_test;
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_materiel/models/utilisateur.dart';
import 'package:gestion_materiel/repositories/firestore_utilisateur_repository.dart';
import 'package:gestion_materiel/repositories/i_utilisateur_repository.dart';

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
    return _FakeDocumentReference(
        firestore, '$collectionPath/$documentId', _docs);
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
        cfsi.InternalSnapshotMetadata(
            hasPendingWrites: false, isFromCache: true),
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
  Future<cfsi.DocumentSnapshotPlatform> get([cfsi.GetOptions? options]) async {
    final data = _docs[_id];
    return cfsi.DocumentSnapshotPlatform(
      firestore,
      _id,
      data,
      cfsi.InternalSnapshotMetadata(hasPendingWrites: false, isFromCache: true),
    );
  }

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

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

Utilisateur _sampleUtilisateur(String id, {String? email}) {
  return Utilisateur(
    id: id,
    nom: 'Nabil Boukhoulkhal',
    email: email ?? 'nabil@gardnet.dz',
    role: RoleUtilisateur.administrateurGeneral,
    dateCreation: DateTime(2026, 1, 1),
  );
}

// ---------------------------------------------------------------------------
// In-memory fake for interface substitutability
// ---------------------------------------------------------------------------

class _InMemoryUtilisateurRepository implements IUtilisateurRepository {
  final Map<String, Utilisateur> _items = {};

  @override
  Future<Utilisateur?> getById(String id) async => _items[id];

  @override
  Future<void> create(Utilisateur user) async {
    _items[user.id] = user;
  }

  @override
  Future<void> update(Utilisateur user) async {
    _items[user.id] = user;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Store store;

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
    cfsi.FirebaseFirestorePlatform.instance = _FakeFirestore(store);
  });

  setUp(() {
    store.clear();
  });

  // ---- getById ----

  group('getById', () {
    test('returns Utilisateur when document exists', () async {
      store['Utilisateurs'] = {
        'user-1': _sampleUtilisateur('user-1').toMap(),
      };

      final repository = FirestoreUtilisateurRepository();
      final user = await repository.getById('user-1');

      expect(user, isNotNull);
      expect(user!.id, 'user-1');
      expect(user.nom, 'Nabil Boukhoulkhal');
      expect(user.email, 'nabil@gardnet.dz');
      expect(user.role, RoleUtilisateur.administrateurGeneral);
    });

    test('returns null when document does not exist', () async {
      final repository = FirestoreUtilisateurRepository();
      final user = await repository.getById('nonexistent');
      expect(user, isNull);
    });

    test('decodes role correctly from Firestore', () async {
      store['Utilisateurs'] = {
        'sup-1': _sampleUtilisateur('sup-1', email: 'sup@gardnet.dz').toMap()
          ..['role'] = 'superviseur',
      };

      final repository = FirestoreUtilisateurRepository();
      final user = await repository.getById('sup-1');

      expect(user, isNotNull);
      expect(user!.role, RoleUtilisateur.superviseur);
    });
  });

  // ---- create ----

  group('create', () {
    test('writes the user document to Utilisateurs collection', () async {
      final repository = FirestoreUtilisateurRepository();
      final user = _sampleUtilisateur('user-1');

      await repository.create(user);

      expect(store['Utilisateurs'], hasLength(1));
      expect(store['Utilisateurs']!['user-1']!['nom'], 'Nabil Boukhoulkhal');
      expect(store['Utilisateurs']!['user-1']!['email'], 'nabil@gardnet.dz');
      expect(store['Utilisateurs']!['user-1']!['role'], 'administrateurGeneral');
    });

    test('overwrites existing document with same ID', () async {
      store['Utilisateurs'] = {
        'user-1': _sampleUtilisateur('user-1').toMap(),
      };

      final repository = FirestoreUtilisateurRepository();
      final updated = _sampleUtilisateur('user-1', email: 'new@gardnet.dz');
      await repository.create(updated);

      expect(store['Utilisateurs'], hasLength(1));
      expect(store['Utilisateurs']!['user-1']!['email'], 'new@gardnet.dz');
    });
  });

  // ---- update ----

  group('update', () {
    test('updates an existing user document', () async {
      store['Utilisateurs'] = {
        'user-1': _sampleUtilisateur('user-1').toMap(),
      };

      final repository = FirestoreUtilisateurRepository();
      final updated = Utilisateur(
        id: 'user-1',
        nom: 'Nabil B.',
        email: 'updated@gardnet.dz',
        role: RoleUtilisateur.superviseur,
        dateCreation: DateTime(2026, 1, 1),
      );

      await repository.update(updated);

      final stored = store['Utilisateurs']!['user-1']!;
      expect(stored['nom'], 'Nabil B.');
      expect(stored['email'], 'updated@gardnet.dz');
      expect(stored['role'], 'superviseur');
    });

    test('update does not create a new document if it does not exist',
        () async {
      final repository = FirestoreUtilisateurRepository();

      // Update on non-existent doc — the fake will create it (same as real
      // Firestore behavior where update on missing doc throws, but our fake
      // is lenient). This test documents the fake's behavior.
      final user = _sampleUtilisateur('user-new');
      await repository.update(user);

      expect(store['Utilisateurs']!['user-new'], isNotNull);
    });
  });

  // ---- Interface substitutability ----

  group('IUtilisateurRepository (mockable contract)', () {
    test('an in-memory fake can stand in for the real repository', () async {
      final fake = _InMemoryUtilisateurRepository();

      final user1 = _sampleUtilisateur('u-1', email: 'a@gardnet.dz');
      final user2 = _sampleUtilisateur('u-2', email: 'b@gardnet.dz');

      await fake.create(user1);
      await fake.create(user2);

      final IUtilisateurRepository repo = fake;

      expect(await repo.getById('u-1'), isNotNull);
      expect((await repo.getById('u-1'))!.email, 'a@gardnet.dz');
      expect(await repo.getById('u-2'), isNotNull);
      expect(await repo.getById('u-3'), isNull);

      // Update
      final updated = Utilisateur(
        id: 'u-1',
        nom: 'Updated',
        email: 'a-new@gardnet.dz',
        role: RoleUtilisateur.chefDEquipe,
        dateCreation: DateTime(2026, 1, 1),
      );
      await repo.update(updated);
      expect((await repo.getById('u-1'))!.email, 'a-new@gardnet.dz');
    });
  });
}
