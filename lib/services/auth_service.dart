import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../di/service_locator.dart';
import '../models/utilisateur.dart';
import '../platform_helper.dart';
import '../repositories/i_utilisateur_repository.dart';

// Création & Développement : Boukhoulkhal Nabil (2026)

class AuthService {
  AuthService({IUtilisateurRepository? repository})
      : _repository = repository ?? getIt<IUtilisateurRepository>();

  // Desktop mode: fake user for demo
  Utilisateur? _desktopUser;

  User? get currentUser {
    if (isDesktop) {
      return _desktopUser != null ? _FakeUser(_desktopUser!) : null;
    }
    return FirebaseAuth.instance.currentUser;
  }

  Stream<User?> get authStateChanges {
    if (isDesktop) {
      return Stream.value(currentUser);
    }
    return FirebaseAuth.instance.authStateChanges();
  }

  final IUtilisateurRepository _repository;

  Future<Utilisateur?> connexion(String email, String password) async {
    if (isDesktop) {
      // Desktop mode: create fake user
      _desktopUser = Utilisateur(
        id: 'desktop-user-1',
        nom: 'Utilisateur Desktop',
        email: email,
        role: RoleUtilisateur.superviseur,
        dateCreation: DateTime.now(),
      );
      return _desktopUser;
    }

    try {
      final credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final utilisateur = await _repository.getById(credential.user!.uid);
        return utilisateur;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(
        code: e.code,
        message: _getLoginErrorMessage(e.code),
      );
    }
  }

  Future<void> deconnexion() async {
    if (isDesktop) {
      _desktopUser = null;
      return;
    }
    await FirebaseAuth.instance.signOut();
  }

  Future<Utilisateur?> inscription({
    required String nom,
    required String email,
    required String password,
    required RoleUtilisateur role,
  }) async {
    if (isDesktop) {
      // Desktop mode: create fake user
      _desktopUser = Utilisateur(
        id: 'desktop-user-${DateTime.now().millisecondsSinceEpoch}',
        nom: nom,
        email: email,
        role: role,
        dateCreation: DateTime.now(),
      );
      return _desktopUser;
    }

    UserCredential? credential;

    try {
      // Step 1: Create user in Firebase Auth
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
    } on FirebaseException catch (e) {
      // Firestore write failed — clean up Auth user to avoid orphan
      await credential.user!.delete().catchError((_) {});
      throw AuthServiceException(
        code: 'firestore-write-failed',
        message: _getFirestoreErrorMessage(e.code),
      );
    }

        return utilisateur;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(
        code: e.code,
        message: _getRegistrationErrorMessage(e.code),
      );
    }
  }

  Future<Utilisateur?> getUtilisateurActuel() async {
    if (isDesktop) {
      return _desktopUser;
    }
    if (currentUser == null) return null;
    return _repository.getById(currentUser!.uid);
  }

  /// Creates a demo account if it doesn't exist yet.
  Future<void> createDemoAccountIfNeeded() async {
    const demoEmail = 'nabil.gardnet@gmail.com';
    const demoPassword = 'Othm@ne2015';
    const demoName = 'boukhoulkhal nabil';
    const demoRole = RoleUtilisateur.superviseur;

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: demoEmail,
        password: demoPassword,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(demoName);

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
      if (e.code == 'email-already-in-use') {
        debugPrint('Demo account email already registered');
      } else {
        debugPrint('Failed to create demo account: ${e.code}');
      }
    } catch (e) {
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
        return 'Erreur de permissions Firestore.';
      case 'unavailable':
        return 'Firestore est temporairement indisponible.';
      case 'deadline-exceeded':
        return 'Délai d\'attente dépassé.';
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

/// Fake User class for desktop mode
class _FakeUser implements User {
  final Utilisateur _utilisateur;

  _FakeUser(this._utilisateur);

  @override
  String get uid => _utilisateur.id;

  @override
  String? get email => _utilisateur.email;

  @override
  String? get displayName => _utilisateur.nom;

  @override
  bool get emailVerified => true;

  @override
  bool get isAnonymous => false;

  @override
  Future<void> updateDisplayName(String? displayName) async {}

  @override
  Future<void> reload() async {}

  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) =>
      throw UnimplementedError();

  @override
  Future<UserCredential> reauthenticateWithCredential(
          AuthCredential credential) =>
      throw UnimplementedError();

  @override
  Future<void> delete() async {}

  @override
  String? get phoneNumber => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Typed exception for AuthService with user-friendly messages.
class AuthServiceException implements Exception {
  final String code;
  final String message;

  const AuthServiceException({required this.code, required this.message});

  @override
  String toString() => message;
}
