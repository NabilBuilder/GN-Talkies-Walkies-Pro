import '../models/materiel.dart';

/// Contract for materiel data access.
///
/// Screens depend on this abstraction instead of touching the Firestore
/// service directly, which makes them testable with in-memory fakes and
/// ready for dependency injection.
abstract class IMaterielRepository {
  /// Streams the full list of materiels, emitting a new list on every change.
  Stream<List<Materiel>> getMateriels();

  /// Creates a new materiel document (upsert by [Materiel.id]).
  Future<void> addMateriel(Materiel materiel);

  /// Updates an existing materiel document.
  Future<void> updateMateriel(Materiel materiel);

  /// Deletes the materiel document with the given [id].
  Future<void> deleteMateriel(String id);
}
