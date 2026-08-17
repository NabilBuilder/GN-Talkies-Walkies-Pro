import '../models/historique_transfert.dart';

/// Contract for transfer history data access.
///
/// The [executeTransfer] method performs an atomic batch operation that
/// either completes fully or fails without side effects.
abstract class IHistoriqueTransfertRepository {
  /// Streams the full transfer history, most recent first.
  Stream<List<HistoriqueTransfert>> getHistory();

  /// Atomically updates the materiel's site and creates a transfer record.
  ///
  /// This is a batch operation: either both writes succeed or neither takes
  /// effect. Throws on failure.
  Future<void> executeTransfer({
    required String materielId,
    required String materielDesignation,
    required String codeQR,
    required String siteOrigine,
    required String siteDestination,
    required String transferePar,
    required String motif,
  });
}
