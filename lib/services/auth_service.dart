import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../models/utilisateur.dart';
import '../repositories/firestore_utilisateur_repository.dart';
import '../repositories/i_utilisateur_repository.dart';

class AuthService {
  AuthService({IUtilisateurRepository? repository})
      : _repository = repository ?? FirestoreUtilisateurRepository();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final IUtilisateurRepository _repository;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Utilisateur?> connexion(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final utilisateur = await _repository.getById(credential.user!.uid);
        return utilisateur;
      }
      return null;
    } on FirebaseAuthException catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Login failed: ${e.code}',
      );
      throw Exception(_getErrorMessage(e.code));
    }
  }

  Future<void> deconnexion() async {
    await _auth.signOut();
  }

  Future<Utilisateur?> inscription({
    required String nom,
    required String email,
    required String password,
    required RoleUtilisateur role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final utilisateur = Utilisateur(
          id: credential.user!.uid,
          nom: nom,
          email: email,
          role: role,
          dateCreation: DateTime.now(),
        );

        await _repository.create(utilisateur);

        return utilisateur;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getInscriptionErrorMessage(e.code));
    }
  }

  String _getInscriptionErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'weak-password':
        return 'Mot de passe trop faible (minimum 6 caractères).';
      default:
        return 'Erreur d\'inscription: $code';
    }
  }

  Future<Utilisateur?> getUtilisateurActuel() async {
    if (currentUser == null) return null;

    return _repository.getById(currentUser!.uid);
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez réessayer plus tard.';
      case 'invalid-credential':
        return 'Identifiants invalides.';
      default:
        return 'Erreur de connexion: $code';
    }
  }
}
