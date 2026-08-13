import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/utilisateur.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Utilisateur?> connexion(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final doc = await _firestore
            .collection('Utilisateurs')
            .doc(credential.user!.uid)
            .get();

        if (doc.exists) {
          return Utilisateur.fromFirestore(doc);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
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

        await _firestore
            .collection('Utilisateurs')
            .doc(credential.user!.uid)
            .set(utilisateur.toMap());

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

    final doc = await _firestore
        .collection('Utilisateurs')
        .doc(currentUser!.uid)
        .get();

    if (doc.exists) {
      return Utilisateur.fromFirestore(doc);
    }
    return null;
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
