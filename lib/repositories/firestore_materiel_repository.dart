import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/materiel.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import 'i_materiel_repository.dart';

/// Firestore-backed [IMaterielRepository] with cache-first strategy.
///
/// First emits cached data from Hive for instant load, then fetches fresh
/// data from Firestore in the background and updates the cache.
/// Création & Développement : Boukhoulkhal Nabil (2026)
class FirestoreMaterielRepository implements IMaterielRepository {
  FirestoreMaterielRepository({
    FirestoreService? service,
    ILocalStorageService? localStorage,
  })  : _service = service ?? FirestoreService(),
        _localStorage = localStorage;

  final FirestoreService _service;
  final ILocalStorageService? _localStorage;

  @override
  Stream<List<Materiel>> getMateriels() {
    final controller = StreamController<List<Materiel>>();

    // Step 1: Emit cached data immediately (if available)
    if (_localStorage != null) {
      final cached = _localStorage.getCachedMateriels();
      if (cached.isNotEmpty) {
        final materiels = cached.map((m) => Materiel.fromMap(m, '')).toList();
        controller.add(materiels);
      }
    }

    // Step 2: Fetch fresh data from Firestore
    _service.getMateriels().listen(
      (materiels) {
        controller.add(materiels);
        // Update cache with fresh data
        if (_localStorage != null) {
          final data = materiels.map((m) => m.toMap()).toList();
          _localStorage.cacheMateriels(data);
        }
      },
      onError: (error) {
        // Keep cached data on error
        if (!controller.isClosed) {
          controller.addError(error);
        }
      },
    );

    return controller.stream;
  }

  @override
  Future<void> addMateriel(Materiel materiel) => _service.creerMateriel(materiel);

  @override
  Future<void> updateMateriel(Materiel materiel) =>
      _service.mettreAJourMateriel(materiel);

  @override
  Future<void> deleteMateriel(String id) => FirebaseFirestore.instance
      .collection('Materiels')
      .doc(id)
      .delete();
}
