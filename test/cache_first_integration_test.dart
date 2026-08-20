import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:gestion_materiel/services/local_storage_service.dart';

/// Integration test for cache-first strategy.
/// Création & Développement : Boukhoulkhal Nabil (2026)
void main() {
  late HiveLocalStorageService storage;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final testDir = '${Directory.current.path}/test/hive_cache_test';
    await Directory(testDir).create(recursive: true);
    Hive.init(testDir);
    storage = HiveLocalStorageService();
    await storage.init(testDir);
  });

  tearDown(() async {
    await storage.clearCache();
  });

  group('Cache-first strategy', () {
    test('should return cached materiels when cache exists', () async {
      // Arrange: Pre-populate cache
      final cachedMateriels = [
        {'codeQR': 'CACHED-001', 'designation': 'Cached Talkie'},
      ];
      await storage.cacheMateriels(cachedMateriels);

      // Act: Get cached data
      final result = storage.getCachedMateriels();

      // Assert: Returns cached data
      expect(result.length, equals(1));
      expect(result[0]['codeQR'], equals('CACHED-001'));
    });

    test('should update cache when fresh data arrives', () async {
      // Arrange: Pre-populate cache
      await storage.cacheMateriels([
        {'codeQR': 'OLD-001', 'designation': 'Old Talkie'},
      ]);

      // Act: Update with fresh data
      final freshData = [
        {'codeQR': 'FRESH-001', 'designation': 'Fresh Talkie'},
        {'codeQR': 'FRESH-002', 'designation': 'Fresh Radio'},
      ];
      await storage.cacheMateriels(freshData);

      // Assert: Cache updated
      final result = storage.getCachedMateriels();
      expect(result.length, equals(2));
      expect(result[0]['codeQR'], equals('FRESH-001'));
    });

    test('should handle empty cache gracefully', () {
      // Act: Get from empty cache
      final result = storage.getCachedMateriels();

      // Assert: Returns empty list
      expect(result, isEmpty);
    });
  });
}
