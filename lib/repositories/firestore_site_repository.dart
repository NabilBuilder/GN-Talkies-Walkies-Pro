import 'dart:async';

import '../models/site.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import 'i_site_repository.dart';

/// Firestore-backed [ISiteRepository] with cache-first strategy.
///
/// First emits cached data from Hive for instant load, then fetches fresh
/// data from Firestore in the background.
/// Création & Développement : Boukhoulkhal Nabil (2026)
class FirestoreSiteRepository implements ISiteRepository {
  FirestoreSiteRepository({
    FirestoreService? service,
    ILocalStorageService? localStorage,
  })  : _service = service ?? FirestoreService(),
        _localStorage = localStorage;

  final FirestoreService _service;
  final ILocalStorageService? _localStorage;

  @override
  Stream<List<Site>> getSites() {
    final controller = StreamController<List<Site>>();

    // Step 1: Emit cached data immediately (if available)
    if (_localStorage != null) {
      final cached = _localStorage.getCachedSites();
      if (cached.isNotEmpty) {
        final sites = cached.map((s) => Site.fromMap(s)).toList();
        controller.add(sites);
      }
    }

    // Step 2: Fetch fresh data from Firestore
    _service.getSites().listen(
      (sites) {
        controller.add(sites);
        // Update cache with fresh data
        if (_localStorage != null) {
          final data = sites.map((s) => s.toMap()).toList();
          _localStorage.cacheSites(data);
        }
      },
      onError: (error) {
        if (!controller.isClosed) {
          controller.addError(error);
        }
      },
    );

    return controller.stream;
  }

  @override
  Future<List<Site>> getSitesList() => _service.getSitesList();
}
