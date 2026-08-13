import 'package:cloud_firestore/cloud_firestore.dart';

enum RoleUtilisateur { administrateurGeneral, superviseur, chefDEquipe }

class Utilisateur {
  final String id;
  final String nom;
  final String email;
  final RoleUtilisateur role;
  final DateTime dateCreation;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.email,
    required this.role,
    required this.dateCreation,
  });

  factory Utilisateur.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Utilisateur(
      id: doc.id,
      nom: data['nom'] ?? '',
      email: data['email'] ?? '',
      role: _roleFromString(data['role'] ?? 'chefDEquipe'),
      dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'email': email,
      'role': role.toString().split('.').last,
      'dateCreation': Timestamp.fromDate(dateCreation),
    };
  }

  static RoleUtilisateur _roleFromString(String role) {
    switch (role) {
      case 'administrateurGeneral':
        return RoleUtilisateur.administrateurGeneral;
      case 'superviseur':
        return RoleUtilisateur.superviseur;
      case 'chefDEquipe':
        return RoleUtilisateur.chefDEquipe;
      default:
        return RoleUtilisateur.chefDEquipe;
    }
  }

  bool get isAdmin => role == RoleUtilisateur.administrateurGeneral;
  bool get isSuperviseur => role == RoleUtilisateur.superviseur || isAdmin;
  bool get isChefEquipe => role == RoleUtilisateur.chefDEquipe;
}
