// Création & Développement : Boukhoulkhal Nabil (2026)

/// Seeds the database with demo data.
/// On desktop (where Firebase is not available), this is a no-op.
class SeedService {
  dynamic _firestore;
  bool _firestoreAvailable = true;

  dynamic _getDb() {
    if (_firestore == null && _firestoreAvailable) {
      try {
        // This will only work on mobile where Firebase is initialized
        _firestore = _getFirestoreInstance();
      } catch (e) {
        _firestoreAvailable = false;
      }
    }
    return _firestore;
  }

  Future<Map<String, int>> seedDatabase() async {
    final db = _getDb();
    if (db == null) {
      // Desktop: return empty results (demo data is provided by InMemory repos)
      return {'Sites': 0, 'Marches': 0, 'Materiels': 0};
    }

    final result = <String, int>{};

    final batch = db.batch();
    var sitesCount = 0;
    var marchesCount = 0;
    var materielsCount = 0;

    final sites = [
      {
        'nom': 'Site Principal - Alger',
        'adresse': 'Zone Industrielle Rouiba',
        'ville': 'Alger',
        'responsable': 'M. Benali',
      },
      {
        'nom': 'Site Oran',
        'adresse': 'Zone Industrielle Es-Sénia',
        'ville': 'Oran',
        'responsable': 'Mme. Mansouri',
      },
      {
        'nom': 'Site Constantine',
        'adresse': 'Zone Industrielle Palma',
        'ville': 'Constantine',
        'responsable': 'M. Khelifi',
      },
    ];

    final siteNames = <String>[];

    for (final site in sites) {
      final ref = db.collection('Sites').doc();
      batch.set(ref, {
        'nom': site['nom'],
        'adresse': site['adresse'],
        'ville': site['ville'],
        'responsable': site['responsable'],
        'dateCreation': DateTime.now(),
      });
      siteNames.add(site['nom'] as String);
      sitesCount++;
    }

    final marches = [
      {
        'numero': 'M2026-001',
        'intitule': 'Maintenance Talkie Walkie - Site Est',
        'client': 'Sonelgaz',
        'budget': 2500000.0,
      },
      {
        'numero': 'M2026-002',
        'intitule': 'Équipement de Communication - Site Ouest',
        'client': 'Entreprise des Télécommunications',
        'budget': 1800000.0,
      },
      {
        'numero': 'M2026-003',
        'intitule': 'Réseau Radios - Sites Sud',
        'client': 'Direction des Travaux Publics',
        'budget': 3200000.0,
      },
    ];

    final marcheNumbers = <String>[];

    for (final marche in marches) {
      final ref = db.collection('Marches').doc();
      batch.set(ref, {
        'numero': marche['numero'],
        'intitule': marche['intitule'],
        'client': marche['client'],
        'dateDebut': DateTime.now(),
        'dateFin': null,
        'budget': marche['budget'],
      });
      marcheNumbers.add(marche['numero'] as String);
      marchesCount++;
    }

    final materiels = [
      {
        'codeQR': 'TW-GARDNET-001',
        'designation': 'Talkie Walkie Motorola GP340',
        'numeroSerie': 'SN-MOT-001',
        'marque': 'Motorola',
        'modele': 'GP340',
        'etat': 'actif',
      },
      {
        'codeQR': 'TW-GARDNET-002',
        'designation': 'Talkie Walkie Kenwood TK-3201',
        'numeroSerie': 'SN-KEN-001',
        'marque': 'Kenwood',
        'modele': 'TK-3201',
        'etat': 'actif',
      },
      {
        'codeQR': 'TW-GARDNET-003',
        'designation': 'Radio Hytera PD785',
        'numeroSerie': 'SN-HYT-001',
        'marque': 'Hytera',
        'modele': 'PD785',
        'etat': 'enPanne',
      },
      {
        'codeQR': 'TW-GARDNET-004',
        'designation': 'Talkie Walkie Icom IC-F4029',
        'numeroSerie': 'SN-ICM-001',
        'marque': 'Icom',
        'modele': 'IC-F4029',
        'etat': 'actif',
      },
    ];

    for (var i = 0; i < materiels.length; i++) {
      final m = materiels[i];
      final ref = db.collection('Materiels').doc();
      batch.set(ref, {
        'codeQR': m['codeQR'],
        'designation': m['designation'],
        'numeroSerie': m['numeroSerie'],
        'marque': m['marque'],
        'modele': m['modele'],
        'etat': m['etat'],
        'siteActuel': siteNames[i % siteNames.length],
        'marche': marcheNumbers[i % marcheNumbers.length],
        'imageUrl': '',
        'dateEnregistrement': DateTime.now(),
        'derniereMiseAJour': DateTime.now(),
        'enregistrePar': '',
      });
      materielsCount++;
    }

    await batch.commit();

    result['Sites'] = sitesCount;
    result['Marches'] = marchesCount;
    result['Materiels'] = materielsCount;

    return result;
  }
}

/// Get Firestore instance — only called on mobile where Firebase is initialized.
dynamic _getFirestoreInstance() {
  throw StateError('Firebase not available on this platform');
}
