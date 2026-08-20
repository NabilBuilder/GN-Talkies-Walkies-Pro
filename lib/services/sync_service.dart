import 'package:cloud_firestore/cloud_firestore.dart';
import 'local_storage_service.dart';

/// Interface for data synchronization operations.
/// Création & Développement : Boukhoulkhal Nabil (2026)
abstract class ISyncService {
  Future<bool> syncAll();
  Future<List<Map<String, dynamic>>> getMateriels({bool forceRefresh = false});
  Future<List<Map<String, dynamic>>> getSites({bool forceRefresh = false});
  Future<List<Map<String, dynamic>>> getMarches({bool forceRefresh = false});
}

/// Firestore-based implementation with Hive offline caching.
/// Création & Développement : Boukhoulkhal Nabil (2026)
class FirestoreSyncService implements ISyncService {
  final ILocalStorageService _localStorage;
  final FirebaseFirestore _firestore;


  FirestoreSyncService({
    required ILocalStorageService localStorage,
    FirebaseFirestore? firestore,
  })  : _localStorage = localStorage,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<bool> syncAll() async {
    try {
      // Fetch all collections from Firestore
      final materiels = await _fetchCollection('Materiels');
      final sites = await _fetchCollection('Sites');
      final marches = await _fetchCollection('Marches');

      // Cache to Hive
      await _localStorage.cacheMateriels(materiels);
      await _localStorage.cacheSites(sites);
      await _localStorage.cacheMarches(marches);

      return true;
    } catch (e) {
      // Return cached data if offline
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMateriels({
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      final data = await _fetchCollection('Materiels');
      await _localStorage.cacheMateriels(data);
      return data;
    }

    final cached = _localStorage.getCachedMateriels();
    if (cached.isNotEmpty) return cached;

    // Fetch from Firestore if cache is empty
    final data = await _fetchCollection('Materiels');
    await _localStorage.cacheMateriels(data);
    return data;
  }

  @override
  Future<List<Map<String, dynamic>>> getSites({
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      final data = await _fetchCollection('Sites');
      await _localStorage.cacheSites(data);
      return data;
    }

    final cached = _localStorage.getCachedSites();
    if (cached.isNotEmpty) return cached;

    final data = await _fetchCollection('Sites');
    await _localStorage.cacheSites(data);
    return data;
  }

  @override
  Future<List<Map<String, dynamic>>> getMarches({
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      final data = await _fetchCollection('Marches');
      await _localStorage.cacheMarches(data);
      return data;
    }

    final cached = _localStorage.getCachedMarches();
    if (cached.isNotEmpty) return cached;

    final data = await _fetchCollection('Marches');
    await _localStorage.cacheMarches(data);
    return data;
  }

  Future<List<Map<String, dynamic>>> _fetchCollection(String collection) async {
    final snapshot = await _firestore.collection(collection).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
