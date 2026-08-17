// Unit tests for FirestoreSiteRepository and FirestoreMarcheRepository.
//
// Reuses the same Fake Firestore singleton pattern established in
// firestore_materiel_repository_test.dart. The in-memory store is shared
// across all test files because FirebaseFirestore.instance is a cached
// singleton — setUpAll installs the fake once, setUp resets the store.
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    as cfsi;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart' as fcp_test;
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_materiel/models/marche.dart';
import 'package:gestion_materiel/models/site.dart';
import 'package:gestion_materiel/repositories/firestore_marche_repository.dart';
import 'package:gestion_materiel/repositories/firestore_site_repository.dart';
import 'package:gestion_materiel/repositories/i_marche_repository.dart';
import 'package:gestion_materiel/repositories/i_site_repository.dart';

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

// ---------------------------------------------------------------------------
// Sample data factories
// ---------------------------------------------------------------------------

Site _sampleSite(String id, {String? nom}) {
  return Site(
    id: id,
    nom: nom ?? 'Site $id',
    adresse: '123 Rue Example',
    ville: 'Alger',
    responsable: 'Responsable $id',
    dateCreation: DateTime(2026, 1, 1),
  );
}

Marche _sampleMarche(String id, {String? numero}) {
  return Marche(
    id: id,
    numero: numero ?? 'M-2026-$id',
    intitule: 'Marché $id',
    client: 'Client $id',
    dateDebut: DateTime(2026, 1, 1),
    budget: 100000.0,
  );
}

// ---------------------------------------------------------------------------
// In-memory fakes proving interface substitutability
// ---------------------------------------------------------------------------

class _InMemorySiteRepository implements ISiteRepository {
  final Map<String, Site> _items = {};

  @override
  Stream<List<Site>> getSites() => Stream.value(_items.values.toList());

  @override
  Future<List<Site>> getSitesList() async => _items.values.toList();

  void addSite(Site site) => _items[site.id] = site;
}

class _InMemoryMarcheRepository implements IMarcheRepository {
  final Map<String, Marche> _items = {};

  @override
  Stream<List<Marche>> getMarches() => Stream.value(_items.values.toList());

  @override
  Future<List<Marche>> getMarchesList() async => _items.values.toList();

  void addMarche(Marche marche) => _items[marche.id] = marche;
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

  // ---- FirestoreSiteRepository ----

  group('FirestoreSiteRepository', () {
    test('getSites streams sites decoded from Firestore', () async {
      store['Sites'] = {
        'site-1': _sampleSite('site-1', nom: 'Site Principal Alger').toMap(),
        'site-2': _sampleSite('site-2', nom: 'Site Oran').toMap(),
      };

      final repository = FirestoreSiteRepository();
      final sites = await repository.getSites().first;

      expect(sites, hasLength(2));
      expect(sites.first.id, 'site-1');
      expect(sites.first.nom, 'Site Principal Alger');
      expect(sites.last.nom, 'Site Oran');
    });

    test('getSitesList returns a future list from Firestore', () async {
      store['Sites'] = {
        'site-1': _sampleSite('site-1').toMap(),
        'site-2': _sampleSite('site-2').toMap(),
        'site-3': _sampleSite('site-3').toMap(),
      };

      final repository = FirestoreSiteRepository();
      final sites = await repository.getSitesList();

      expect(sites, hasLength(3));
      expect(sites.map((s) => s.id).toSet(),
          containsAll(['site-1', 'site-2', 'site-3']));
    });

    test('getSites returns empty stream when collection is empty', () async {
      final repository = FirestoreSiteRepository();
      final sites = await repository.getSites().first;
      expect(sites, isEmpty);
    });
  });

  // ---- FirestoreMarcheRepository ----

  group('FirestoreMarcheRepository', () {
    test('getMarches streams marches decoded from Firestore', () async {
      store['Marches'] = {
        'marche-1': _sampleMarche('marche-1', numero: 'M-001').toMap(),
        'marche-2': _sampleMarche('marche-2', numero: 'M-002').toMap(),
      };

      final repository = FirestoreMarcheRepository();
      final marches = await repository.getMarches().first;

      expect(marches, hasLength(2));
      expect(marches.first.id, 'marche-1');
      expect(marches.first.numero, 'M-001');
      expect(marches.last.numero, 'M-002');
    });

    test('getMarchesList returns a future list from Firestore', () async {
      store['Marches'] = {
        'marche-1': _sampleMarche('marche-1').toMap(),
      };

      final repository = FirestoreMarcheRepository();
      final marches = await repository.getMarchesList();

      expect(marches, hasLength(1));
      expect(marches.first.client, 'Client marche-1');
    });

    test('getMarches returns empty stream when collection is empty', () async {
      final repository = FirestoreMarcheRepository();
      final marches = await repository.getMarches().first;
      expect(marches, isEmpty);
    });

    test('getMarches decodes budget as double', () async {
      store['Marches'] = {
        'marche-1': _sampleMarche('marche-1').toMap(),
      };

      final repository = FirestoreMarcheRepository();
      final marches = await repository.getMarches().first;

      expect(marches.first.budget, 100000.0);
    });
  });

  // ---- Interface substitutability (ISiteRepository) ----

  group('ISiteRepository (mockable contract)', () {
    test('an in-memory fake can stand in for the real repository', () async {
      final fake = _InMemorySiteRepository();
      fake.addSite(_sampleSite('s-1', nom: 'Alger'));
      fake.addSite(_sampleSite('s-2', nom: 'Oran'));

      final ISiteRepository siteRepo = fake;
      final sites = await siteRepo.getSitesList();
      expect(sites, hasLength(2));
      expect(sites.map((s) => s.nom).toSet(), containsAll({'Alger', 'Oran'}));

      final streamSites = await siteRepo.getSites().first;
      expect(streamSites, hasLength(2));
    });
  });

  // ---- Interface substitutability (IMarcheRepository) ----

  group('IMarcheRepository (mockable contract)', () {
    test('an in-memory fake can stand in for the real repository', () async {
      final fake = _InMemoryMarcheRepository();
      fake.addMarche(_sampleMarche('m-1', numero: 'M-001'));
      fake.addMarche(_sampleMarche('m-2', numero: 'M-002'));

      final IMarcheRepository marcheRepo = fake;
      final marches = await marcheRepo.getMarchesList();
      expect(marches, hasLength(2));
      expect(marches.map((m) => m.numero).toSet(),
          containsAll({'M-001', 'M-002'}));

      final streamMarches = await marcheRepo.getMarches().first;
      expect(streamMarches, hasLength(2));
    });
  });
}
