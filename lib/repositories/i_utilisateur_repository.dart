import '../models/utilisateur.dart';

/// Contract for utilisateur (user) data access.
abstract class IUtilisateurRepository {
  /// Fetches a user by their document ID (Firebase Auth UID).
  Future<Utilisateur?> getById(String id);

  /// Creates a new user document.
  Future<void> create(Utilisateur user);

  /// Updates an existing user document.
  Future<void> update(Utilisateur user);
}
