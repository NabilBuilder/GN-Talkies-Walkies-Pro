import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/materiel.dart';
import '../services/firestore_service.dart';
import 'i_materiel_repository.dart';

/// Firestore-backed [IMaterielRepository].
///
/// Wraps [FirestoreService] for the operations it already provides. The only
/// operation missing from the service — [deleteMateriel] — is performed
/// directly against the Firestore collection so the service itself can stay
/// untouched.
class FirestoreMaterielRepository implements IMaterielRepository {
  FirestoreMaterielRepository({FirestoreService? service})
      : _service = service ?? FirestoreService();

  final FirestoreService _service;

  @override
  Stream<List<Materiel>> getMateriels() => _service.getMateriels();

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
