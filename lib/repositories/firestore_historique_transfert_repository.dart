import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/historique_transfert.dart';
import '../services/firestore_service.dart';
import 'i_historique_transfert_repository.dart';

/// Firestore-backed [IHistoriqueTransfertRepository].
///
/// Delegates reads to [FirestoreService]. The atomic [executeTransfer] batch
/// operation is performed directly against Firestore so the batch commit
/// logic stays in one place (this repository) without touching the service.
class FirestoreHistoriqueTransfertRepository
    implements IHistoriqueTransfertRepository {
  FirestoreHistoriqueTransfertRepository({FirestoreService? service})
      : _service = service ?? FirestoreService();

  final FirestoreService _service;

  @override
  Stream<List<HistoriqueTransfert>> getHistory() =>
      _service.getHistoriqueTransferts();

  @override
  Future<void> executeTransfer({
    required String materielId,
    required String materielDesignation,
    required String codeQR,
    required String siteOrigine,
    required String siteDestination,
    required String transferePar,
    required String motif,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // Update the materiel's current site.
    final materielRef = firestore.collection('Materiels').doc(materielId);
    batch.update(materielRef, {
      'siteActuel': siteDestination,
      'derniereMiseAJour': Timestamp.fromDate(DateTime.now()),
    });

    // Create the transfer history record.
    final transfertId = firestore.collection('Historique_Transferts').doc().id;
    final transfertRef =
        firestore.collection('Historique_Transferts').doc(transfertId);
    batch.set(transfertRef, HistoriqueTransfert(
      id: transfertId,
      materielId: materielId,
      materielDesignation: materielDesignation,
      codeQR: codeQR,
      siteOrigine: siteOrigine,
      siteDestination: siteDestination,
      transferePar: transferePar,
      motif: motif,
      dateTransfert: DateTime.now(),
    ).toMap());

    await batch.commit();
  }
}
