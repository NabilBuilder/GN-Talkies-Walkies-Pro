import '../models/marche.dart';

/// Contract for marche (market/contract) data access.
abstract class IMarcheRepository {
  /// Streams the full list of marches.
  Stream<List<Marche>> getMarches();

  /// Fetches the current list of marches as a one-shot Future.
  Future<List<Marche>> getMarchesList();
}
