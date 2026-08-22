import 'package:flutter/foundation.dart';
import '../di/service_locator.dart';
import '../models/utilisateur.dart';
import '../platform_helper.dart';
import '../repositories/i_utilisateur_repository.dart';

// Création & Développement : Boukhoulkhal Nabil (2026)

/// Firebase Auth import — deferred, loaded only on mobile.
import 'package:firebase_auth/firebase_auth.dart' deferred as fb_auth;

class AuthService {
  AuthService({IUtilisateurRepository? repository})
      : _repository = repository ?? getIt<IUtilisateurRepository>();

  // Desktop mode: fake user for demo
  Utilisateur? _desktopUser;

  // Firebase auth — use dynamic to avoid deferred type issues in declarations.
  dynamic _firebaseAuth;
  bool _authLibraryLoaded = false;

  /// Lazily loads firebase_auth library and gets the instance.
  Future<dynamic> _getFirebaseAuth() async {
    if (_firebaseAuth == null) {
      if (!_authLibraryLoaded) {
        try {
          await fb_auth.loadLibrary();
          _authLibraryLoaded = true;
        } catch (e) {
          debugPrint('Failed to load firebase_auth library: $e');
          return null;
        }
      }
      try {
        _firebaseAuth = fb_auth.FirebaseAuth.instance;
      } catch (e) {
        debugPrint('Failed to get FirebaseAuth instance: $e');
        return null;
      }
    }
    return _firebaseAuth;
  }

  dynamic get currentUser {
    if (isDesktop) {
      return _desktopUser != null ? _FakeUser(_desktopUser!) : null;
    }
    // On mobile, this must be called asynchronously
    return null;
  }

  Future<dynamic> getCurrentUserAsync() async {
    if (isDesktop) {
      return _desktopUser != null ? _FakeUser(_desktopUser!) : null;
    }
    try {
      final auth = await _getFirebaseAuth();
      if (auth == null) return null;
      return auth.currentUser;
    } catch (e) {
      debugPrint('Failed to get current user: $e');
      return null;
    }
  }

  Stream<dynamic> get authStateChanges async* {
    if (isDesktop) {
      yield currentUser;
      return;
    }
    try {
      final auth = await _getFirebaseAuth();
      if (auth == null) {
        yield null;
        return;
      }
      yield* auth.authStateChanges();
    } catch (e) {
      debugPrint('Auth state changes error: $e');
      yield null;
    }
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
      final auth = await _getFirebaseAuth();
      if (auth == null) {
        throw AuthServiceException(
          code: 'firebase-unavailable',
          message: 'Firebase is not available.',
        );
      }
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final utilisateur = await _repository.getById(credential.user!.uid);
        return utilisateur;
      }
      return null;
    } catch (e) {
      // Catch Firebase errors and translate to user-friendly messages
      final code = _extractFirebaseErrorCode(e);
      if (code != null) {
        throw AuthServiceException(
          code: code,
          message: _getLoginErrorMessage(code),
        );
      }
      rethrow;
    }
  }

  Future<void> deconnexion() async {
    if (isDesktop) {
      _desktopUser = null;
      return;
    }
    try {
      final auth = await _getFirebaseAuth();
      if (auth != null) {
        await auth.signOut();
      }
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
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

    dynamic credential;

    try {
      final auth = await _getFirebaseAuth();
      if (auth == null) {
        throw AuthServiceException(
          code: 'firebase-unavailable',
          message: 'Firebase is not available.',
        );
      }
      // Step 1: Create user in Firebase Auth
      credential = await auth.createUserWithEmailAndPassword(
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
        } catch (e) {
          // Firestore write failed — clean up Auth user to avoid orphan
          await credential.user!.delete().catchError((_) {});
          throw AuthServiceException(
            code: 'firestore-write-failed',
            message: 'Erreur lors de la création du profil utilisateur.',
          );
        }

        return utilisateur;
      }
      return null;
    } catch (e) {
      // Catch Firebase errors and translate to user-friendly messages
      final code = _extractFirebaseErrorCode(e);
      if (code != null) {
        throw AuthServiceException(
          code: code,
          message: _getRegistrationErrorMessage(code),
        );
      }
      rethrow;
    }
  }

  Future<Utilisateur?> getUtilisateurActuel() async {
    if (isDesktop) {
      return _desktopUser;
    }
    final user = await getCurrentUserAsync();
    if (user == null) return null;
    return _repository.getById(user.uid);
  }

  /// Creates a demo account if it doesn't exist yet.
  Future<void> createDemoAccountIfNeeded() async {
    if (isDesktop) return; // Skip on desktop

    const demoEmail = 'nabil.gardnet@gmail.com';
    const demoPassword = 'Othm@ne2015';
    const demoName = 'boukhoulkhal nabil';
    const demoRole = RoleUtilisateur.superviseur;

    try {
      final auth = await _getFirebaseAuth();
      if (auth == null) return;
      final credential = await auth.createUserWithEmailAndPassword(
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
    } catch (e) {
      final code = _extractFirebaseErrorCode(e);
      if (code == 'email-already-in-use') {
        debugPrint('Demo account email already registered');
      } else {
        debugPrint('Demo account creation skipped: $code');
      }
    }
  }

  /// Extracts Firebase error code from any exception type.
  String? _extractFirebaseErrorCode(dynamic error) {
    try {
      // Try to access .code property dynamically
      final code = (error as dynamic).code;
      if (code is String && code.isNotEmpty) return code;
    } catch (_) {}
    return null;
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
class _FakeUser {
  final Utilisateur _utilisateur;

  _FakeUser(this._utilisateur);

  String get uid => _utilisateur.id;
  String? get email => _utilisateur.email;
  String? get displayName => _utilisateur.nom;
  bool get emailVerified => true;
  bool get isAnonymous => false;

  Future<void> updateDisplayName(String? displayName) async {}
  Future<void> reload() async {}
  Future<void> delete() async {}
  String? get phoneNumber => null;
}

/// Typed exception for AuthService with user-friendly messages.
class AuthServiceException implements Exception {
  final String code;
  final String message;

  const AuthServiceException({required this.code, required this.message});

  @override
  String toString() => message;
}
