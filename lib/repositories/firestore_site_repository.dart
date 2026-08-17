import '../models/site.dart';
import '../services/firestore_service.dart';
import 'i_site_repository.dart';

/// Firestore-backed [ISiteRepository] delegating to [FirestoreService].
class FirestoreSiteRepository implements ISiteRepository {
  FirestoreSiteRepository({FirestoreService? service})
      : _service = service ?? FirestoreService();

  final FirestoreService _service;

  @override
  Stream<List<Site>> getSites() => _service.getSites();

  @override
  Future<List<Site>> getSitesList() => _service.getSitesList();
}
