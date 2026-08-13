import 'package:cloud_firestore/cloud_firestore.dart';

class HistoriqueTransfert {
  final String id;
  final String materielId;
  final String materielDesignation;
  final String codeQR;
  final String siteOrigine;
  final String siteDestination;
  final String transferePar;
  final String motif;
  final DateTime dateTransfert;
  final bool confirme;
  final String confirmePar;
  final DateTime? dateConfirmation;

  HistoriqueTransfert({
    required this.id,
    required this.materielId,
    required this.materielDesignation,
    required this.codeQR,
    required this.siteOrigine,
    required this.siteDestination,
    required this.transferePar,
    required this.motif,
    required this.dateTransfert,
    this.confirme = false,
    this.confirmePar = '',
    this.dateConfirmation,
  });

  factory HistoriqueTransfert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HistoriqueTransfert(
      id: doc.id,
      materielId: data['materielId'] ?? '',
      materielDesignation: data['materielDesignation'] ?? '',
      codeQR: data['codeQR'] ?? '',
      siteOrigine: data['siteOrigine'] ?? '',
      siteDestination: data['siteDestination'] ?? '',
      transferePar: data['transferePar'] ?? '',
      motif: data['motif'] ?? '',
      dateTransfert: (data['dateTransfert'] as Timestamp?)?.toDate() ?? DateTime.now(),
      confirme: data['confirme'] ?? false,
      confirmePar: data['confirmePar'] ?? '',
      dateConfirmation: (data['dateConfirmation'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'materielId': materielId,
      'materielDesignation': materielDesignation,
      'codeQR': codeQR,
      'siteOrigine': siteOrigine,
      'siteDestination': siteDestination,
      'transferePar': transferePar,
      'motif': motif,
      'dateTransfert': Timestamp.fromDate(dateTransfert),
      'confirme': confirme,
      'confirmePar': confirmePar,
      'dateConfirmation': dateConfirmation != null ? Timestamp.fromDate(dateConfirmation!) : null,
    };
  }

  HistoriqueTransfert copyWith({
    String? id,
    String? materielId,
    String? materielDesignation,
    String? codeQR,
    String? siteOrigine,
    String? siteDestination,
    String? transferePar,
    String? motif,
    DateTime? dateTransfert,
    bool? confirme,
    String? confirmePar,
    DateTime? dateConfirmation,
  }) {
    return HistoriqueTransfert(
      id: id ?? this.id,
      materielId: materielId ?? this.materielId,
      materielDesignation: materielDesignation ?? this.materielDesignation,
      codeQR: codeQR ?? this.codeQR,
      siteOrigine: siteOrigine ?? this.siteOrigine,
      siteDestination: siteDestination ?? this.siteDestination,
      transferePar: transferePar ?? this.transferePar,
      motif: motif ?? this.motif,
      dateTransfert: dateTransfert ?? this.dateTransfert,
      confirme: confirme ?? this.confirme,
      confirmePar: confirmePar ?? this.confirmePar,
      dateConfirmation: dateConfirmation ?? this.dateConfirmation,
    );
  }
}
