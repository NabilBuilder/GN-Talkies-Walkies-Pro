import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/materiel.dart';
import '../models/site.dart';
import '../models/marche.dart';
import '../models/historique_transfert.dart';
import '../models/utilisateur.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService() {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // === UTILISATEURS ===
  Future<void> creerUtilisateur(Utilisateur user) async {
    await _firestore.collection('Utilisateurs').doc(user.id).set(user.toMap());
  }

  Future<List<Utilisateur>> getUtilisateurs() async {
    final snapshot = await _firestore.collection('Utilisateurs').get();
    return snapshot.docs.map((doc) => Utilisateur.fromFirestore(doc)).toList();
  }

  // === MATERIELS ===
  Future<void> creerMateriel(Materiel materiel) async {
    await _firestore.collection('Materiels').doc(materiel.id).set(materiel.toMap());
  }

  Future<void> mettreAJourMateriel(Materiel materiel) async {
    await _firestore.collection('Materiels').doc(materiel.id).update(materiel.toMap());
  }

  Future<Materiel?> getMaterielByCodeQR(String codeQR) async {
    final snapshot = await _firestore
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
    final doc = await _firestore.collection('Materiels').doc(id).get();
    if (doc.exists) {
      return Materiel.fromFirestore(doc);
    }
    return null;
  }

  Stream<List<Materiel>> getMateriels() {
    return _firestore.collection('Materiels').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Materiel.fromFirestore(doc)).toList(),
    );
  }

  Future<List<Materiel>> getMaterielsList() async {
    final snapshot = await _firestore.collection('Materiels').get();
    return snapshot.docs.map((doc) => Materiel.fromFirestore(doc)).toList();
  }

  Future<List<Materiel>> getMaterielsParSite(String site) async {
    final snapshot = await _firestore
        .collection('Materiels')
        .where('siteActuel', isEqualTo: site)
        .get();
    return snapshot.docs.map((doc) => Materiel.fromFirestore(doc)).toList();
  }

  // === SITES ===
  Future<void> creerSite(Site site) async {
    await _firestore.collection('Sites').doc(site.id).set(site.toMap());
  }

  Stream<List<Site>> getSites() {
    return _firestore.collection('Sites').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Site.fromFirestore(doc)).toList(),
    );
  }

  Future<List<Site>> getSitesList() async {
    final snapshot = await _firestore.collection('Sites').get();
    return snapshot.docs.map((doc) => Site.fromFirestore(doc)).toList();
  }

  // === MARCHES ===
  Future<void> creerMarche(Marche marche) async {
    await _firestore.collection('Marches').doc(marche.id).set(marche.toMap());
  }

  Stream<List<Marche>> getMarches() {
    return _firestore.collection('Marches').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Marche.fromFirestore(doc)).toList(),
    );
  }

  Future<List<Marche>> getMarchesList() async {
    final snapshot = await _firestore.collection('Marches').get();
    return snapshot.docs.map((doc) => Marche.fromFirestore(doc)).toList();
  }

  // === HISTORIQUE TRANSFERTS ===
  Future<void> creerTransfert(HistoriqueTransfert transfert) async {
    await _firestore
        .collection('Historique_Transferts')
        .doc(transfert.id)
        .set(transfert.toMap());
  }

  Stream<List<HistoriqueTransfert>> getHistoriqueTransferts() {
    return _firestore
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
    await _firestore
        .collection('Historique_Transferts')
        .doc(transfertId)
        .update({
      'confirme': true,
      'confirmePar': confirmePar,
      'dateConfirmation': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> effectuerTransfert({
    required Materiel materiel,
    required String siteDestination,
    required String transferePar,
    required String motif,
  }) async {
    final batch = _firestore.batch();

    // Mettre à jour le site du matériel
    final materielRef = _firestore.collection('Materiels').doc(materiel.id);
    batch.update(materielRef, {
      'siteActuel': siteDestination,
      'derniereMiseAJour': Timestamp.fromDate(DateTime.now()),
    });

    // Créer l'historique
    final transfertId = _firestore.collection('Historique_Transferts').doc().id;
    final transfertRef = _firestore.collection('Historique_Transferts').doc(transfertId);
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
