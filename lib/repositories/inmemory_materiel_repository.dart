import 'dart:async';
import '../models/materiel.dart';
import 'i_materiel_repository.dart';

/// In-memory implementation for desktop platforms where Firebase is unavailable.
/// Returns demo data on first call, then works with local list.
/// Création & Développement : Boukhoulkhal Nabil (2026)
class InMemoryMaterielRepository implements IMaterielRepository {
  final List<Materiel> _materiels = [];
  final StreamController<List<Materiel>> _controller =
      StreamController<List<Materiel>>.broadcast();

  InMemoryMaterielRepository() {
    if (_materiels.isEmpty) {
      _loadDemoData();
    }
  }

  void _loadDemoData() {
    final now = DateTime.now();
    _materiels.addAll([
      Materiel(
        id: 'demo-1',
        codeQR: 'QR-TW-001',
        designation: 'Talkie Walkie Motorola T82',
        numeroSerie: 'TW-2024-001',
        marque: 'Motorola',
        modele: 'T82',
        etat: EtatMateriel.actif,
        siteActuel: 'Site Alger Centre',
        marche: 'Marché Public 2024',
        dateEnregistrement: now.subtract(const Duration(days: 90)),
        derniereMiseAJour: now,
        enregistrePar: 'demo@gn.com',
      ),
      Materiel(
        id: 'demo-2',
        codeQR: 'QR-AN-001',
        designation: 'Antenne HF Comet',
        numeroSerie: 'AN-2024-001',
        marque: 'Comet',
        modele: 'C11',
        etat: EtatMateriel.actif,
        siteActuel: 'Site Oran',
        marche: 'Marché Privé 2024',
        dateEnregistrement: now.subtract(const Duration(days: 60)),
        derniereMiseAJour: now,
        enregistrePar: 'demo@gn.com',
      ),
      Materiel(
        id: 'demo-3',
        codeQR: 'QR-BT-001',
        designation: 'Batterie Li-Ion 3800mAh',
        numeroSerie: 'BT-2024-001',
        marque: 'Generic',
        modele: '3800mAh',
        etat: EtatMateriel.enPanne,
        siteActuel: 'Site Constantine',
        marche: 'Marché Maintenance',
        dateEnregistrement: now.subtract(const Duration(days: 180)),
        derniereMiseAJour: now,
        enregistrePar: 'demo@gn.com',
      ),
      Materiel(
        id: 'demo-4',
        codeQR: 'QR-CH-001',
        designation: 'Chargeur Multi-Ports',
        numeroSerie: 'CH-2024-001',
        marque: 'ChargerPro',
        modele: '6Port',
        etat: EtatMateriel.actif,
        siteActuel: 'Site Alger Centre',
        marche: 'Marché Public 2024',
        dateEnregistrement: now.subtract(const Duration(days: 30)),
        derniereMiseAJour: now,
        enregistrePar: 'demo@gn.com',
      ),
      Materiel(
        id: 'demo-5',
        codeQR: 'QR-EC-001',
        designation: 'Écouteur Combiné Loud',
        numeroSerie: 'EC-2024-001',
        marque: 'AudioPro',
        modele: 'Loud100',
        etat: EtatMateriel.perdu,
        siteActuel: 'Site Oran',
        marche: 'Marché Privé 2024',
        dateEnregistrement: now.subtract(const Duration(days: 300)),
        derniereMiseAJour: now,
        enregistrePar: 'demo@gn.com',
      ),
    ]);
  }

  @override
  Stream<List<Materiel>> getMateriels() {
    _controller.add(List.unmodifiable(_materiels));
    return _controller.stream;
  }

  @override
  Future<void> addMateriel(Materiel materiel) async {
    _materiels.add(materiel);
    _controller.add(List.unmodifiable(_materiels));
  }

  @override
  Future<void> updateMateriel(Materiel materiel) async {
    final index = _materiels.indexWhere((m) => m.id == materiel.id);
    if (index != -1) {
      _materiels[index] = materiel;
      _controller.add(List.unmodifiable(_materiels));
    }
  }

  @override
  Future<void> deleteMateriel(String id) async {
    _materiels.removeWhere((m) => m.id == id);
    _controller.add(List.unmodifiable(_materiels));
  }
}
