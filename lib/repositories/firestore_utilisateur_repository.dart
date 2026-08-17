import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/utilisateur.dart';
import 'i_utilisateur_repository.dart';

/// Firestore-backed [IUtilisateurRepository].
///
/// Performs CRUD directly against the 'Utilisateurs' collection.
/// [AuthService] delegates to this repository for Firestore operations
/// while handling Firebase Auth separately.
class FirestoreUtilisateurRepository implements IUtilisateurRepository {
  static const _collection = 'Utilisateurs';

  @override
  Future<Utilisateur?> getById(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection(_collection)
        .doc(id)
        .get();
    if (doc.exists) {
      return Utilisateur.fromFirestore(doc);
    }
    return null;
  }

  @override
  Future<void> create(Utilisateur user) async {
    await FirebaseFirestore.instance
        .collection(_collection)
        .doc(user.id)
        .set(user.toMap());
  }

  @override
  Future<void> update(Utilisateur user) async {
    await FirebaseFirestore.instance
        .collection(_collection)
        .doc(user.id)
        .update(user.toMap());
  }
}
