import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gestion_materiel/services/local_storage_service.dart';

/// Création & Développement : Boukhoulkhal Nabil (2026)
void main() {
  late HiveLocalStorageService storage;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Initialize Hive with a test directory
    final testDir = '${Directory.current.path}/test/hive_test';
    await Directory(testDir).create(recursive: true);
    storage = HiveLocalStorageService();
    await storage.init(testDir);
  });

  tearDown(() async {
    await storage.clearCache();
  });

  group('Materiels caching', () {
    test('should cache and retrieve materiels', () async {
      final materiels = [
        {'codeQR': 'TW-001', 'designation': 'Talkie Walkie'},
        {'codeQR': 'TW-002', 'designation': 'Radio Hytera'},
      ];

      await storage.cacheMateriels(materiels);
      final cached = storage.getCachedMateriels();

      expect(cached.length, equals(2));
      expect(cached[0]['codeQR'], equals('TW-001'));
      expect(cached[1]['designation'], equals('Radio Hytera'));
    });

    test('should return empty list when no materiels cached', () {
      final cached = storage.getCachedMateriels();
      expect(cached, isEmpty);
    });
  });

  group('Sites caching', () {
    test('should cache and retrieve sites', () async {
      final sites = [
        {'nom': 'Site Alger', 'ville': 'Alger'},
        {'nom': 'Site Oran', 'ville': 'Oran'},
      ];

      await storage.cacheSites(sites);
      final cached = storage.getCachedSites();

      expect(cached.length, equals(2));
      expect(cached[0]['nom'], equals('Site Alger'));
    });
  });

  group('Marches caching', () {
    test('should cache and retrieve marches', () async {
      final marches = [
        {'numero': 'M2026-001', 'intitule': 'Maintenance'},
      ];

      await storage.cacheMarches(marches);
      final cached = storage.getCachedMarches();

      expect(cached.length, equals(1));
      expect(cached[0]['numero'], equals('M2026-001'));
    });
  });

  group('Clear cache', () {
    test('should clear all cached data', () async {
      await storage.cacheMateriels([{'test': 'data'}]);
      await storage.cacheSites([{'test': 'data'}]);
      await storage.cacheMarches([{'test': 'data'}]);

      await storage.clearCache();

      expect(storage.getCachedMateriels(), isEmpty);
      expect(storage.getCachedSites(), isEmpty);
      expect(storage.getCachedMarches(), isEmpty);
    });
  });
}
