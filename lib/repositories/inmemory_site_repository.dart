import 'dart:async';
import '../models/site.dart';
import 'i_site_repository.dart';

/// In-memory implementation for desktop platforms.
/// Returns demo data on first call.
/// Création & Développement : Boukhoulkhal Nabil (2026)
class InMemorySiteRepository implements ISiteRepository {
  final List<Site> _sites = [];
  final StreamController<List<Site>> _controller =
      StreamController<List<Site>>.broadcast();

  InMemorySiteRepository() {
    if (_sites.isEmpty) {
      _loadDemoData();
    }
  }

  void _loadDemoData() {
    final now = DateTime.now();
    _sites.addAll([
      Site(
        id: 'site-1',
        nom: 'Site Alger Centre',
        adresse: 'Rue Didouche Mourad, Alger',
        ville: 'Alger',
        responsable: 'Ahmed Benali',
        dateCreation: now.subtract(const Duration(days: 365)),
      ),
      Site(
        id: 'site-2',
        nom: 'Site Oran',
        adresse: 'Boulevard Front de Mer, Oran',
        ville: 'Oran',
        responsable: 'Karim Mebarki',
        dateCreation: now.subtract(const Duration(days: 300)),
      ),
      Site(
        id: 'site-3',
        nom: 'Site Constantine',
        adresse: 'Avenue Aouati Mostefa, Constantine',
        ville: 'Constantine',
        responsable: 'Youcef Hamidi',
        dateCreation: now.subtract(const Duration(days: 200)),
      ),
    ]);
  }

  @override
  Stream<List<Site>> getSites() {
    _controller.add(List.unmodifiable(_sites));
    return _controller.stream;
  }

  @override
  Future<List<Site>> getSitesList() async {
    return List.unmodifiable(_sites);
  }
}
