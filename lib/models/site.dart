import 'package:cloud_firestore/cloud_firestore.dart';

class Site {
  final String id;
  final String nom;
  final String adresse;
  final String ville;
  final String responsable;
  final DateTime dateCreation;

  Site({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.ville,
    required this.responsable,
    required this.dateCreation,
  });

  factory Site.fromMap(Map<String, dynamic> data) {
    return Site(
      id: data['id'] ?? '',
      nom: data['nom'] ?? '',
      adresse: data['adresse'] ?? '',
      ville: data['ville'] ?? '',
      responsable: data['responsable'] ?? '',
      dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory Site.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Site(
      id: doc.id,
      nom: data['nom'] ?? '',
      adresse: data['adresse'] ?? '',
      ville: data['ville'] ?? '',
      responsable: data['responsable'] ?? '',
      dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'adresse': adresse,
      'ville': ville,
      'responsable': responsable,
      'dateCreation': Timestamp.fromDate(dateCreation),
    };
  }

  @override
  String toString() => nom;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Site && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
