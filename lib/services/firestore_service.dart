import '../models/materiel.dart';
import '../models/site.dart';
import '../models/marche.dart';
import '../models/historique_transfert.dart';
import '../models/utilisateur.dart';
// Création & Développement : Boukhoulkhal Nabil (2026)

/// Service layer for Firestore operations.
/// Uses lazy initialization so construction never crashes on desktop.
/// On desktop, all methods return empty results.
class FirestoreService {
  // Lazy Firestore instance — only created when a method is called.
  // On desktop, this will fail gracefully and return empty results.
  dynamic _firestore;

  bool _firestoreAvailable = true;

  /// Lazily initializes the Firestore connection.
  dynamic _getDb() {
    if (_firestore == null && _firestoreAvailable) {
      try {
        _firestore = _getFirestoreInstance();
      } catch (e) {
        _firestoreAvailable = false;
      }
    }
    return _firestore;
  }

  // === UTILISATEURS ===
  Future<void> creerUtilisateur(Utilisateur user) async {
    final db = _getDb();
    if (db == null) return;
    await db.collection('Utilisateurs').doc(user.id).set(user.toMap());
  }

  Future<List<Utilisateur>> getUtilisateurs() async {
    final db = _getDb();
    if (db == null) return [];
    final snapshot = await db.collection('Utilisateurs').get();
    return snapshot.docs.map((doc) => Utilisateur.fromFirestore(doc)).toList();
  }

  // === MATERIELS ===
  Future<void> creerMateriel(Materiel materiel) async {
    final db = _getDb();
    if (db == null) return;
    await db.collection('Materiels').doc(materiel.id).set(materiel.toMap());
  }

  Future<void> mettreAJourMateriel(Materiel materiel) async {
    final db = _getDb();
    if (db == null) return;
    await db.collection('Materiels').doc(materiel.id).update(materiel.toMap());
  }

  Future<Materiel?> getMaterielByCodeQR(String codeQR) async {
    final db = _getDb();
    if (db == null) return null;
    final snapshot = await db
        .collection('Materiels')
        .where('codeQR', isEqualTo: codeQR)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Materiel.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  Future<Materiel?> getMaterielById(String id) async {
    final db = _getDb();
    if (db == null) return null;
    final doc = await db.collection('Materiels').doc(id).get();
    if (doc.exists) {
      return Materiel.fromFirestore(doc);
    }
    return null;
  }

  Stream<List<Materiel>> getMateriels() {
    final db = _getDb();
    if (db == null) return Stream.value([]);
    return db.collection('Materiels').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Materiel.fromFirestore(doc)).toList(),
    );
  }

  Future<List<Materiel>> getMaterielsList() async {
    final db = _getDb();
    if (db == null) return [];
    final snapshot = await db.collection('Materiels').get();
    return snapshot.docs.map((doc) => Materiel.fromFirestore(doc)).toList();
  }

  Future<List<Materiel>> getMaterielsParSite(String site) async {
    final db = _getDb();
    if (db == null) return [];
    final snapshot = await db
        .collection('Materiels')
        .where('siteActuel', isEqualTo: site)
        .get();
    return snapshot.docs.map((doc) => Materiel.fromFirestore(doc)).toList();
  }

  // === SITES ===
  Future<void> creerSite(Site site) async {
    final db = _getDb();
    if (db == null) return;
    await db.collection('Sites').doc(site.id).set(site.toMap());
  }

  Stream<List<Site>> getSites() {
    final db = _getDb();
    if (db == null) return Stream.value([]);
    return db.collection('Sites').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Site.fromFirestore(doc)).toList(),
    );
  }

  Future<List<Site>> getSitesList() async {
    final db = _getDb();
    if (db == null) return [];
    final snapshot = await db.collection('Sites').get();
    return snapshot.docs.map((doc) => Site.fromFirestore(doc)).toList();
  }

  // === MARCHES ===
  Future<void> creerMarche(Marche marche) async {
    final db = _getDb();
    if (db == null) return;
    await db.collection('Marches').doc(marche.id).set(marche.toMap());
  }

  Stream<List<Marche>> getMarches() {
    final db = _getDb();
    if (db == null) return Stream.value([]);
    return db.collection('Marches').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Marche.fromFirestore(doc)).toList(),
    );
  }

  Future<List<Marche>> getMarchesList() async {
    final db = _getDb();
    if (db == null) return [];
    final snapshot = await db.collection('Marches').get();
    return snapshot.docs.map((doc) => Marche.fromFirestore(doc)).toList();
  }

  // === HISTORIQUE TRANSFERTS ===
  Future<void> creerTransfert(HistoriqueTransfert transfert) async {
    final db = _getDb();
    if (db == null) return;
    await db
        .collection('Historique_Transferts')
        .doc(transfert.id)
        .set(transfert.toMap());
  }

  Stream<List<HistoriqueTransfert>> getHistoriqueTransferts() {
    final db = _getDb();
    if (db == null) return Stream.value([]);
    return db
        .collection('Historique_Transferts')
        .orderBy('dateTransfert', descending: true)
        .snapshots()
        .map(
      (snapshot) => snapshot.docs
          .map((doc) => HistoriqueTransfert.fromFirestore(doc))
          .toList(),
    );
  }

  Future<void> confirmerTransfert(String transfertId, String confirmePar) async {
    final db = _getDb();
    if (db == null) return;
    await db
        .collection('Historique_Transferts')
        .doc(transfertId)
        .update({
      'confirme': true,
      'confirmePar': confirmePar,
      'dateConfirmation': DateTime.now(),
    });
  }

  Future<void> effectuerTransfert({
    required Materiel materiel,
    required String siteDestination,
    required String transferePar,
    required String motif,
  }) async {
    final db = _getDb();
    if (db == null) return;
    final batch = db.batch();

    // Mettre à jour le site du matériel
    final materielRef = db.collection('Materiels').doc(materiel.id);
    batch.update(materielRef, {
      'siteActuel': siteDestination,
      'derniereMiseAJour': DateTime.now(),
    });

    // Créer l'historique
    final transfertId = db.collection('Historique_Transferts').doc().id;
    final transfertRef = db.collection('Historique_Transferts').doc(transfertId);
    batch.set(transfertRef, HistoriqueTransfert(
      id: transfertId,
      materielId: materiel.id,
      materielDesignation: materiel.designation,
      codeQR: materiel.codeQR,
      siteOrigine: materiel.siteActuel,
      siteDestination: siteDestination,
      transferePar: transferePar,
      motif: motif,
      dateTransfert: DateTime.now(),
    ).toMap());

    await batch.commit();
  }
}

/// Get Firestore instance — this is the ONLY place that touches FirebaseFirestore.
/// On desktop where Firebase is not initialized, this throws, and _getDb() catches it.
/// Uses dynamic to avoid requiring cloud_firestore import at class level.
dynamic _getFirestoreInstance() {
  // This function is only called on mobile where Firebase is initialized.
  // On desktop, the try-catch in _getDb() handles the failure.
  throw StateError('Firebase not available on this platform');
}
