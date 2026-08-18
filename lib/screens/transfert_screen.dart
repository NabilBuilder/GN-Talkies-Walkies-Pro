import 'package:flutter/material.dart';
import '../di/service_locator.dart';
import '../models/materiel.dart';
import '../models/site.dart';
import '../repositories/i_historique_transfert_repository.dart';
import '../repositories/i_site_repository.dart';

class TransfertScreen extends StatefulWidget {
  final Materiel materiel;

  const TransfertScreen({super.key, required this.materiel});

  @override
  State<TransfertScreen> createState() => _TransfertScreenState();
}

class _TransfertScreenState extends State<TransfertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motifController = TextEditingController();
  // DI: Injected via GetIt
  final IHistoriqueTransfertRepository _transfertRepository =
      getIt<IHistoriqueTransfertRepository>();
  // DI: Injected via GetIt
  final ISiteRepository _siteRepository = getIt<ISiteRepository>();
  String? _selectedDestination;
  List<Site> _sites = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  Future<void> _loadSites() async {
    final sites = await _siteRepository.getSitesList();
    setState(() {
      _sites = sites.where((s) => s.nom != widget.materiel.siteActuel).toList();
    });
  }

  @override
  void dispose() {
    _motifController.dispose();
    super.dispose();
  }

  Future<void> _effectuerTransfert() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _transfertRepository.executeTransfer(
        materielId: widget.materiel.id,
        materielDesignation: widget.materiel.designation,
        codeQR: widget.materiel.codeQR,
        siteOrigine: widget.materiel.siteActuel,
        siteDestination: _selectedDestination!,
        transferePar: '',
        motif: _motifController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transfert effectué avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfert de matériel'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Matériel à transférer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _buildInfoRow('Désignation', widget.materiel.designation),
                      _buildInfoRow('Code QR', widget.materiel.codeQR),
                      _buildInfoRow('Site actuel', widget.materiel.siteActuel),
                      _buildInfoRow('Marché', widget.materiel.marche),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations de transfert',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDestination,
                        decoration: const InputDecoration(
                          labelText: 'Site de destination *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        items: _sites.map((site) {
                          return DropdownMenuItem(
                            value: site.nom,
                            child: Text(site.nom),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedDestination = value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner un site de destination';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _motifController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Motif du transfert *',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un motif';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _effectuerTransfert,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Effectuer le transfert',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
