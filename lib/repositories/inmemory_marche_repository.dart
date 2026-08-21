import 'dart:async';
import '../models/marche.dart';
import 'i_marche_repository.dart';

/// In-memory implementation for desktop platforms.
/// Returns demo data on first call.
/// Création & Développement : Boukhoulkhal Nabil (2026)
class InMemoryMarcheRepository implements IMarcheRepository {
  final List<Marche> _marches = [];
  final StreamController<List<Marche>> _controller =
      StreamController<List<Marche>>.broadcast();

  InMemoryMarcheRepository() {
    if (_marches.isEmpty) {
      _loadDemoData();
    }
  }

  void _loadDemoData() {
    final now = DateTime.now();
    _marches.addAll([
      Marche(
        id: 'marche-1',
        numero: 'MP-2024-001',
        intitule: 'Marché Public 2024',
        client: 'Direction Générale',
        dateDebut: now,
        dateFin: now.add(const Duration(days: 365)),
        budget: 500000.0,
      ),
      Marche(
        id: 'marche-2',
        numero: 'MP-2024-002',
        intitule: 'Marché Privé 2024',
        client: 'Entreprise XYZ',
        dateDebut: now,
        dateFin: now.add(const Duration(days: 180)),
        budget: 250000.0,
      ),
      Marche(
        id: 'marche-3',
        numero: 'MP-2024-003',
        intitule: 'Marché Maintenance',
        client: 'Service Technique',
        dateDebut: now,
        dateFin: now.add(const Duration(days: 90)),
        budget: 100000.0,
      ),
    ]);
  }

  @override
  Stream<List<Marche>> getMarches() {
    _controller.add(List.unmodifiable(_marches));
    return _controller.stream;
  }

  @override
  Future<List<Marche>> getMarchesList() async {
    return List.unmodifiable(_marches);
  }
}
