import 'package:cloud_firestore/cloud_firestore.dart';

class Marche {
  final String id;
  final String numero;
  final String intitule;
  final String client;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final double budget;

  Marche({
    required this.id,
    required this.numero,
    required this.intitule,
    required this.client,
    required this.dateDebut,
    this.dateFin,
    required this.budget,
  });

  factory Marche.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Marche(
      id: doc.id,
      numero: data['numero'] ?? '',
      intitule: data['intitule'] ?? '',
      client: data['client'] ?? '',
      dateDebut: (data['dateDebut'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateFin: (data['dateFin'] as Timestamp?)?.toDate(),
      budget: (data['budget'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numero': numero,
      'intitule': intitule,
      'client': client,
      'dateDebut': Timestamp.fromDate(dateDebut),
      'dateFin': dateFin != null ? Timestamp.fromDate(dateFin!) : null,
      'budget': budget,
    };
  }

  @override
  String toString() => '$numero - $intitule';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Marche && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
