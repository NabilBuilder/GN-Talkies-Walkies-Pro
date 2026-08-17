import '../models/marche.dart';
import '../services/firestore_service.dart';
import 'i_marche_repository.dart';

/// Firestore-backed [IMarcheRepository] delegating to [FirestoreService].
class FirestoreMarcheRepository implements IMarcheRepository {
  FirestoreMarcheRepository({FirestoreService? service})
      : _service = service ?? FirestoreService();

  final FirestoreService _service;

  @override
  Stream<List<Marche>> getMarches() => _service.getMarches();

  @override
  Future<List<Marche>> getMarchesList() => _service.getMarchesList();
}
