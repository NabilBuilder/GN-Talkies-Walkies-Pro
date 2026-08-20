import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../models/utilisateur.dart';
import '../repositories/firestore_utilisateur_repository.dart';
import '../repositories/i_utilisateur_repository.dart';

// Création & Développement : Boukhoulkhal Nabil (2026)

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
      throw AuthServiceException(
        code: e.code,
        message: _getLoginErrorMessage(e.code),
      );
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
    UserCredential? credential;

    try {
      // Step 1: Create user in Firebase Auth
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(nom);

        // Step 2: Create user profile in Firestore
        final utilisateur = Utilisateur(
          id: credential.user!.uid,
          nom: nom,
          email: email,
          role: role,
          dateCreation: DateTime.now(),
        );

        try {
          await _repository.create(utilisateur);
        } on FirebaseException catch (e, stackTrace) {
          // Firestore write failed — clean up Auth user to avoid orphan
          await credential.user!.delete().catchError((_) {});
          await FirebaseCrashlytics.instance.recordError(
            e,
            stackTrace,
            reason: 'Firestore profile creation failed: ${e.code}',
          );
          throw AuthServiceException(
            code: 'firestore-write-failed',
            message: _getFirestoreErrorMessage(e.code),
          );
        }

        return utilisateur;
      }
      return null;
    } on FirebaseAuthException catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Registration auth failed: ${e.code}',
      );
      throw AuthServiceException(
        code: e.code,
        message: _getRegistrationErrorMessage(e.code),
      );
    }
  }

  Future<Utilisateur?> getUtilisateurActuel() async {
    if (currentUser == null) return null;
    return _repository.getById(currentUser!.uid);
  }

  /// Creates a demo account if it doesn't exist yet.
  /// This allows users to quickly test the app without manual registration.
  Future<void> createDemoAccountIfNeeded() async {
    const demoEmail = 'nabil.gardnet@gmail.com';
    const demoPassword = 'Othm@ne2015';
    const demoName = 'boukhoulkhal nabil';
    const demoRole = RoleUtilisateur.superviseur;

    try {
      // Try to create the demo account
      // If email already exists, Firebase will throw 'email-already-in-use'
      final credential = await _auth.createUserWithEmailAndPassword(
        email: demoEmail,
        password: demoPassword,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(demoName);

        // Create Firestore profile
        final demoUser = Utilisateur(
          id: credential.user!.uid,
          nom: demoName,
          email: demoEmail,
          role: demoRole,
          dateCreation: DateTime.now(),
        );

        await _repository.create(demoUser);
        debugPrint('Demo account created successfully');
      }
    } on FirebaseAuthException catch (e) {
      // If email already in use, that's fine - demo account exists
      if (e.code == 'email-already-in-use') {
        debugPrint('Demo account email already registered');
      } else {
        debugPrint('Failed to create demo account: ${e.code}');
      }
    } catch (e) {
      // Any other error - log but don't crash
      debugPrint('Demo account creation skipped: $e');
    }
  }

  String _getRegistrationErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'weak-password':
        return 'Mot de passe trop faible (minimum 6 caractères).';
      case 'operation-not-allowed':
        return 'Cette méthode de connexion n\'est pas activée.';
      default:
        return 'Erreur d\'inscription: $code';
    }
  }

  String _getFirestoreErrorMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Erreur de permissions Firestore. Vérifiez les règles de sécurité.';
      case 'unavailable':
        return 'Firestore est temporairement indisponible.';
      case 'deadline-exceeded':
        return 'Délai d\'attente dépassé. Vérifiez votre connexion.';
      default:
        return 'Erreur Firestore: $code';
    }
  }

  String _getLoginErrorMessage(String code) {
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
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion Internet.';
      default:
        return 'Erreur de connexion: $code';
    }
  }
}

/// Typed exception for AuthService with user-friendly messages.
class AuthServiceException implements Exception {
  final String code;
  final String message;

  const AuthServiceException({required this.code, required this.message});

  @override
  String toString() => message;
}
