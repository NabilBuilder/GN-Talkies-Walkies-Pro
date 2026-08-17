import '../models/site.dart';

/// Contract for site data access.
abstract class ISiteRepository {
  /// Streams the full list of sites.
  Stream<List<Site>> getSites();

  /// Fetches the current list of sites as a one-shot Future.
  Future<List<Site>> getSitesList();
}
