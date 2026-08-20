import 'package:hive_flutter/hive_flutter.dart';

/// Interface for local storage operations.
/// Création & Développement : Boukhoulkhal Nabil (2026)
abstract class ILocalStorageService {
  Future<void> init();
  Future<void> cacheMateriels(List<Map<String, dynamic>> materiels);
  List<Map<String, dynamic>> getCachedMateriels();
  Future<void> cacheSites(List<Map<String, dynamic>> sites);
  List<Map<String, dynamic>> getCachedSites();
  Future<void> cacheMarches(List<Map<String, dynamic>> marches);
  List<Map<String, dynamic>> getCachedMarches();
  Future<void> clearCache();
}

/// Hive-based implementation of local storage service.
/// Création & Développement : Boukhoulkhal Nabil (2026)
class HiveLocalStorageService implements ILocalStorageService {
  static const String _materielsBox = 'materiels';
  static const String _sitesBox = 'sites';
  static const String _marchesBox = 'marches';

  late Box<List> _materielsStorage;
  late Box<List> _sitesStorage;
  late Box<List> _marchesStorage;

  @override
  Future<void> init([String? path]) async {
    if (path != null) {
      Hive.init(path);
    } else {
      await Hive.initFlutter();
    }
    _materielsStorage = await Hive.openBox<List>(_materielsBox);
    _sitesStorage = await Hive.openBox<List>(_sitesBox);
    _marchesStorage = await Hive.openBox<List>(_marchesBox);
  }

  @override
  Future<void> cacheMateriels(List<Map<String, dynamic>> materiels) async {
    await _materielsStorage.put('data', materiels);
  }

  @override
  List<Map<String, dynamic>> getCachedMateriels() {
    final data = _materielsStorage.get('data');
    if (data == null) return [];
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> cacheSites(List<Map<String, dynamic>> sites) async {
    await _sitesStorage.put('data', sites);
  }

  @override
  List<Map<String, dynamic>> getCachedSites() {
    final data = _sitesStorage.get('data');
    if (data == null) return [];
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> cacheMarches(List<Map<String, dynamic>> marches) async {
    await _marchesStorage.put('data', marches);
  }

  @override
  List<Map<String, dynamic>> getCachedMarches() {
    final data = _marchesStorage.get('data');
    if (data == null) return [];
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> clearCache() async {
    await _materielsStorage.clear();
    await _sitesStorage.clear();
    await _marchesStorage.clear();
  }
}
