import 'dart:async';

import '../models/marche.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import 'i_marche_repository.dart';

/// Firestore-backed [IMarcheRepository] with cache-first strategy.
///
/// First emits cached data from Hive for instant load, then fetches fresh
/// data from Firestore in the background.
/// Création & Développement : Boukhoulkhal Nabil (2026)
class FirestoreMarcheRepository implements IMarcheRepository {
  FirestoreMarcheRepository({
    FirestoreService? service,
    ILocalStorageService? localStorage,
  })  : _service = service ?? FirestoreService(),
        _localStorage = localStorage;

  final FirestoreService _service;
  final ILocalStorageService? _localStorage;

  @override
  Stream<List<Marche>> getMarches() {
    final controller = StreamController<List<Marche>>();

    // Step 1: Emit cached data immediately (if available)
    if (_localStorage != null) {
      final cached = _localStorage.getCachedMarches();
      if (cached.isNotEmpty) {
        final marches = cached.map((m) => Marche.fromMap(m)).toList();
        controller.add(marches);
      }
    }

    // Step 2: Fetch fresh data from Firestore
    _service.getMarches().listen(
      (marches) {
        controller.add(marches);
        // Update cache with fresh data
        if (_localStorage != null) {
          final data = marches.map((m) => m.toMap()).toList();
          _localStorage.cacheMarches(data);
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
  Future<List<Marche>> getMarchesList() => _service.getMarchesList();
}
