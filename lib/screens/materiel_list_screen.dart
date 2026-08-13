import 'package:flutter/material.dart';
import '../models/materiel.dart';
import '../services/firestore_service.dart';
import 'materiel_form_screen.dart';
import 'transfert_screen.dart';

class MaterielListScreen extends StatefulWidget {
  const MaterielListScreen({super.key});

  @override
  State<MaterielListScreen> createState() => _MaterielListScreenState();
}

class _MaterielListScreenState extends State<MaterielListScreen> {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _filterEtat;


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getEtatColor(EtatMateriel etat) {
    switch (etat) {
      case EtatMateriel.actif:
        return Colors.green;
      case EtatMateriel.enPanne:
        return Colors.orange;
      case EtatMateriel.perdu:
        return Colors.red;
    }
  }

  IconData _getEtatIcon(EtatMateriel etat) {
    switch (etat) {
      case EtatMateriel.actif:
        return Icons.check_circle;
      case EtatMateriel.enPanne:
        return Icons.warning;
      case EtatMateriel.perdu:
        return Icons.cancel;
    }
  }

  String _getEtatLabel(EtatMateriel etat) {
    switch (etat) {
      case EtatMateriel.actif:
        return 'Actif';
      case EtatMateriel.enPanne:
        return 'En panne';
      case EtatMateriel.perdu:
        return 'Perdu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un matériel...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _filterEtat,
                        decoration: const InputDecoration(
                          labelText: 'Filtrer par état',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Tous')),
                          DropdownMenuItem(value: 'actif', child: Text('Actif')),
                          DropdownMenuItem(value: 'enPanne', child: Text('En panne')),
                          DropdownMenuItem(value: 'perdu', child: Text('Perdu')),
                        ],
                        onChanged: (value) {
                          setState(() => _filterEtat = value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Materiel>>(
              stream: _firestoreService.getMateriels(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var materiels = snapshot.data!;

                if (_searchQuery.isNotEmpty) {
                  materiels = materiels.where((m) {
                    return m.designation.toLowerCase().contains(_searchQuery) ||
                        m.codeQR.toLowerCase().contains(_searchQuery) ||
                        m.numeroSerie.toLowerCase().contains(_searchQuery) ||
                        m.marque.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (_filterEtat != null) {
                  materiels = materiels.where((m) {
                    return m.etat.toString().split('.').last == _filterEtat;
                  }).toList();
                }

                if (materiels.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Aucun matériel trouvé',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: materiels.length,
                  itemBuilder: (context, index) {
                    final materiel = materiels[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getEtatColor(materiel.etat).withValues(alpha: 0.1),
                          child: Icon(
                            _getEtatIcon(materiel.etat),
                            color: _getEtatColor(materiel.etat),
                          ),
                        ),
                        title: Text(
                          materiel.designation,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('QR: ${materiel.codeQR}'),
                            Text('Site: ${materiel.siteActuel}'),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getEtatColor(materiel.etat).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getEtatLabel(materiel.etat),
                                style: TextStyle(
                                  color: _getEtatColor(materiel.etat),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'modifier',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Modifier'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'transfert',
                              child: Row(
                                children: [
                                  Icon(Icons.swap_horiz, size: 20),
                                  SizedBox(width: 8),
                                  Text('Transférer'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'modifier') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MaterielFormScreen(
                                    materiel: materiel,
                                  ),
                                ),
                              );
                            } else if (value == 'transfert') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransfertScreen(
                                    materiel: materiel,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
