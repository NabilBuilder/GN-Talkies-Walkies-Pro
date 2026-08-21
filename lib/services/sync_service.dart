import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';

/// Interface for data synchronization operations.
/// Création & Développement : Boukhoulkhal Nabil (2026)
abstract class ISyncService {
  Future<bool> syncAll();
  Future<List<Map<String, dynamic>>> getMateriels({bool forceRefresh = false});
  Future<List<Map<String, dynamic>>> getSites({bool forceRefresh = false});
  Future<List<Map<String, dynamic>>> getMarches({bool forceRefresh = false});
  Future<void> initializeDemoDataIfNeeded();
}

/// Firestore-based implementation with Hive offline caching.
/// Création & Développement : Boukhoulkhal Nabil (2026)
class FirestoreSyncService implements ISyncService {
  final ILocalStorageService _localStorage;
  final FirebaseFirestore _firestore;

  FirestoreSyncService({
    required ILocalStorageService localStorage,
    FirebaseFirestore? firestore,
  })  : _localStorage = localStorage,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<bool> syncAll() async {
    try {
      // Fetch all collections from Firestore
      final materiels = await _fetchCollection('Materiels');
      final sites = await _fetchCollection('Sites');
      final marches = await _fetchCollection('Marches');

      // Cache to Hive
      await _localStorage.cacheMateriels(materiels);
      await _localStorage.cacheSites(sites);
      await _localStorage.cacheMarches(marches);

      return true;
    } catch (e) {
      // Return cached data if offline
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMateriels({
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      final data = await _fetchCollection('Materiels');
      await _localStorage.cacheMateriels(data);
      return data;
    }

    final cached = _localStorage.getCachedMateriels();
    if (cached.isNotEmpty) return cached;

    // Fetch from Firestore if cache is empty
    final data = await _fetchCollection('Materiels');
    await _localStorage.cacheMateriels(data);
    return data;
  }

  @override
  Future<List<Map<String, dynamic>>> getSites({
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      final data = await _fetchCollection('Sites');
      await _localStorage.cacheSites(data);
      return data;
    }

    final cached = _localStorage.getCachedSites();
    if (cached.isNotEmpty) return cached;

    final data = await _fetchCollection('Sites');
    await _localStorage.cacheSites(data);
    return data;
  }

  @override
  Future<List<Map<String, dynamic>>> getMarches({
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      final data = await _fetchCollection('Marches');
      await _localStorage.cacheMarches(data);
      return data;
    }

    final cached = _localStorage.getCachedMarches();
    if (cached.isNotEmpty) return cached;

    final data = await _fetchCollection('Marches');
    await _localStorage.cacheMarches(data);
    return data;
  }

  Future<List<Map<String, dynamic>>> _fetchCollection(String collection) async {
    final snapshot = await _firestore.collection(collection).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Initializes demo data if collections are empty.
  /// Creates sample Sites, Marches, and Materiels for testing.
  @override
  Future<void> initializeDemoDataIfNeeded() async {
    try {
      // Check if data already exists
      final sitesCount = await _firestore.collection('Sites').count().get();
      if ((sitesCount.count ?? 0) > 0) {
        debugPrint('Demo data already exists, skipping initialization');
        return;
      }

      debugPrint('Initializing demo data...');

      // Create sample Sites
      final sites = [
        {
          'nom': 'Site Alger Centre',
          'adresse': 'Rue Didouche Mourad, Alger',
          'wilaya': 'Alger',
          'responsable': 'Ahmed Benali',
          'dateCreation': Timestamp.now(),
        },
        {
          'nom': 'Site Oran',
          'adresse': 'Boulevard Front de Mer, Oran',
          'wilaya': 'Oran',
          'responsable': 'Karim Mebarki',
          'dateCreation': Timestamp.now(),
        },
        {
          'nom': 'Site Constantine',
          'adresse': 'Avenue Aouati Mostefa, Constantine',
          'wilaya': 'Constantine',
          'responsable': 'Youcef Hamidi',
          'dateCreation': Timestamp.now(),
        },
      ];

      for (final site in sites) {
        await _firestore.collection('Sites').add(site);
      }

      // Create sample Marchés
      final marches = [
        {
          'numero': 'MP-2024-001',
          'objet': 'Marché Public 2024',
          'client': 'Direction Générale',
          'montant': 500000.0,
          'dateDebut': Timestamp.now(),
          'dateFin': Timestamp.fromDate(
              DateTime.now().add(const Duration(days: 365))),
          'statif': 'en_cours',
        },
        {
          'numero': 'MP-2024-002',
          'objet': 'Marché Privé 2024',
          'client': 'Entreprise XYZ',
          'montant': 250000.0,
          'dateDebut': Timestamp.now(),
          'dateFin': Timestamp.fromDate(
              DateTime.now().add(const Duration(days: 180))),
          'statif': 'en_cours',
        },
        {
          'numero': 'MP-2024-003',
          'objet': 'Marché Maintenance',
          'client': 'Service Technique',
          'montant': 100000.0,
          'dateDebut': Timestamp.now(),
          'dateFin': Timestamp.fromDate(
              DateTime.now().add(const Duration(days: 90))),
          'statif': 'en_cours',
        },
      ];

      for (final marche in marches) {
        await _firestore.collection('Marches').add(marche);
      }

      // Create sample Matériels
      final materiels = [
        {
          'denomination': 'Talkie Walkie Motorola T82',
          'numeroSerie': 'TW-2024-001',
          'etat': 'operational',
          'siteId': '', // Will be updated after sites are created
          'marcheId': '', // Will be updated after marches are created
          'dateAcquisition': Timestamp.now(),
          'dureeVie': 60,
          'dureeUtilisation': 12,
          'prix': 150.0,
          'description': 'Talkie Walkie numérique professional',
        },
        {
          'denomination': 'Antenne HF Comet',
          'numeroSerie': 'AN-2024-001',
          'etat': 'operational',
          'siteId': '',
          'marcheId': '',
          'dateAcquisition': Timestamp.now(),
          'dureeVie': 120,
          'dureeUtilisation': 6,
          'prix': 450.0,
          'description': 'Antenne haute fréquence pour communications longue portée',
        },
        {
          'denomination': 'Batterie Li-Ion 3800mAh',
          'numeroSerie': 'BT-2024-001',
          'etat': 'inRepair',
          'siteId': '',
          'marcheId': '',
          'dateAcquisition': Timestamp.now(),
          'dureeVie': 24,
          'dureeUtilisation': 18,
          'prix': 45.0,
          'description': 'Batterie de rechange pour talkies',
        },
        {
          'denomination': 'Chargeur Multi-Ports',
          'numeroSerie': 'CH-2024-001',
          'etat': 'operational',
          'siteId': '',
          'marcheId': '',
          'dateAcquisition': Timestamp.now(),
          'dureeVie': 60,
          'dureeUtilisation': 3,
          'prix': 120.0,
          'description': 'Chargeur 6 ports pour Talkies',
        },
        {
          'denomination': 'Écouteur Combiné Loud',
          'numeroSerie': 'EC-2024-001',
          'etat': 'lost',
          'siteId': '',
          'marcheId': '',
          'dateAcquisition': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 180))),
          'dureeVie': 36,
          'dureeUtilisation': 12,
          'prix': 85.0,
          'description': 'Écouteur avec micro pour communications discrètes',
        },
      ];

      for (final materiel in materiels) {
        await _firestore.collection('Materiels').add(materiel);
      }

      debugPrint('Demo data initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize demo data: $e');
      // Don't crash - app continues without demo data
    }
  }


}
