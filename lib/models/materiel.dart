import 'package:cloud_firestore/cloud_firestore.dart';

enum EtatMateriel { actif, enPanne, perdu }

class Materiel {
  final String id;
  final String codeQR;
  final String designation;
  final String numeroSerie;
  final String marque;
  final String modele;
  final EtatMateriel etat;
  final String siteActuel;
  final String marche;
  final String imageUrl;
  final DateTime dateEnregistrement;
  final DateTime derniereMiseAJour;
  final String enregistrePar;

  Materiel({
    required this.id,
    required this.codeQR,
    required this.designation,
    required this.numeroSerie,
    required this.marque,
    required this.modele,
    required this.etat,
    required this.siteActuel,
    required this.marche,
    this.imageUrl = '',
    required this.dateEnregistrement,
    required this.derniereMiseAJour,
    required this.enregistrePar,
  });

  factory Materiel.fromMap(Map<String, dynamic> data, String id) {
    return Materiel(
      id: id,
      codeQR: data['codeQR'] ?? '',
      designation: data['designation'] ?? '',
      numeroSerie: data['numeroSerie'] ?? '',
      marque: data['marque'] ?? '',
      modele: data['modele'] ?? '',
      etat: EtatMateriel.values.firstWhere(
        (e) => e.name == data['etat'],
        orElse: () => EtatMateriel.actif,
      ),
      siteActuel: data['siteActuel'] ?? '',
      marche: data['marche'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      dateEnregistrement: (data['dateEnregistrement'] as Timestamp?)?.toDate() ?? DateTime.now(),
      derniereMiseAJour: (data['derniereMiseAJour'] as Timestamp?)?.toDate() ?? DateTime.now(),
      enregistrePar: data['enregistrePar'] ?? '',
    );
  }

  factory Materiel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Materiel(
      id: doc.id,
      codeQR: data['codeQR'] ?? '',
      designation: data['designation'] ?? '',
      numeroSerie: data['numeroSerie'] ?? '',
      marque: data['marque'] ?? '',
      modele: data['modele'] ?? '',
      etat: _etatFromString(data['etat'] ?? 'actif'),
      siteActuel: data['siteActuel'] ?? '',
      marche: data['marche'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      dateEnregistrement: (data['dateEnregistrement'] as Timestamp?)?.toDate() ?? DateTime.now(),
      derniereMiseAJour: (data['derniereMiseAJour'] as Timestamp?)?.toDate() ?? DateTime.now(),
      enregistrePar: data['enregistrePar'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'codeQR': codeQR,
      'designation': designation,
      'numeroSerie': numeroSerie,
      'marque': marque,
      'modele': modele,
      'etat': etat.toString().split('.').last,
      'siteActuel': siteActuel,
      'marche': marche,
      'imageUrl': imageUrl,
      'dateEnregistrement': Timestamp.fromDate(dateEnregistrement),
      'derniereMiseAJour': Timestamp.fromDate(derniereMiseAJour),
      'enregistrePar': enregistrePar,
    };
  }

  static EtatMateriel _etatFromString(String etat) {
    switch (etat) {
      case 'actif':
        return EtatMateriel.actif;
      case 'enPanne':
        return EtatMateriel.enPanne;
      case 'perdu':
        return EtatMateriel.perdu;
      default:
        return EtatMateriel.actif;
    }
  }

  Materiel copyWith({
    String? id,
    String? codeQR,
    String? designation,
    String? numeroSerie,
    String? marque,
    String? modele,
    EtatMateriel? etat,
    String? siteActuel,
    String? marche,
    String? imageUrl,
    DateTime? dateEnregistrement,
    DateTime? derniereMiseAJour,
    String? enregistrePar,
  }) {
    return Materiel(
      id: id ?? this.id,
      codeQR: codeQR ?? this.codeQR,
      designation: designation ?? this.designation,
      numeroSerie: numeroSerie ?? this.numeroSerie,
      marque: marque ?? this.marque,
      modele: modele ?? this.modele,
      etat: etat ?? this.etat,
      siteActuel: siteActuel ?? this.siteActuel,
      marche: marche ?? this.marche,
      imageUrl: imageUrl ?? this.imageUrl,
      dateEnregistrement: dateEnregistrement ?? this.dateEnregistrement,
      derniereMiseAJour: derniereMiseAJour ?? this.derniereMiseAJour,
      enregistrePar: enregistrePar ?? this.enregistrePar,
    );
  }
}
