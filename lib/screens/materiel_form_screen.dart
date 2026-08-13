import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/materiel.dart';
import '../models/site.dart';
import '../models/marche.dart';
import '../services/firestore_service.dart';

class MaterielFormScreen extends StatefulWidget {
  final Materiel? materiel;
  final String? codeQR;

  const MaterielFormScreen({super.key, this.materiel, this.codeQR});

  @override
  State<MaterielFormScreen> createState() => _MaterielFormScreenState();
}

class _MaterielFormScreenState extends State<MaterielFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _imagePicker = ImagePicker();

  late TextEditingController _codeQRController;
  late TextEditingController _designationController;
  late TextEditingController _numeroSerieController;
  late TextEditingController _marqueController;
  late TextEditingController _modeleController;

  EtatMateriel _etat = EtatMateriel.actif;
  String? _selectedSite;
  String? _selectedMarche;
  File? _photo;
  bool _isLoading = false;

  List<Site> _sites = [];
  List<Marche> _marches = [];

  @override
  void initState() {
    super.initState();
    _codeQRController = TextEditingController(
      text: widget.materiel?.codeQR ?? widget.codeQR ?? '',
    );
    _designationController = TextEditingController(
      text: widget.materiel?.designation ?? '',
    );
    _numeroSerieController = TextEditingController(
      text: widget.materiel?.numeroSerie ?? '',
    );
    _marqueController = TextEditingController(
      text: widget.materiel?.marque ?? '',
    );
    _modeleController = TextEditingController(
      text: widget.materiel?.modele ?? '',
    );

    if (widget.materiel != null) {
      _etat = widget.materiel!.etat;
      _selectedSite = widget.materiel!.siteActuel;
      _selectedMarche = widget.materiel!.marche;
    }

    _loadSites();
    _loadMarches();
  }

  Future<void> _loadSites() async {
    final sites = await _firestoreService.getSitesList();
    setState(() => _sites = sites);
  }

  Future<void> _loadMarches() async {
    final marches = await _firestoreService.getMarchesList();
    setState(() => _marches = marches);
  }

  @override
  void dispose() {
    _codeQRController.dispose();
    _designationController.dispose();
    _numeroSerieController.dispose();
    _marqueController.dispose();
    _modeleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() => _photo = File(pickedFile.path));
    }
  }

  Future<void> _saveMateriel() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();

      if (widget.materiel != null) {
        final updated = widget.materiel!.copyWith(
          codeQR: _codeQRController.text.trim(),
          designation: _designationController.text.trim(),
          numeroSerie: _numeroSerieController.text.trim(),
          marque: _marqueController.text.trim(),
          modele: _modeleController.text.trim(),
          etat: _etat,
          siteActuel: _selectedSite ?? '',
          marche: _selectedMarche ?? '',
          derniereMiseAJour: now,
        );
        await _firestoreService.mettreAJourMateriel(updated);
      } else {
        final newId = DateTime.now().millisecondsSinceEpoch.toString();
        final materiel = Materiel(
          id: newId,
          codeQR: _codeQRController.text.trim(),
          designation: _designationController.text.trim(),
          numeroSerie: _numeroSerieController.text.trim(),
          marque: _marqueController.text.trim(),
          modele: _modeleController.text.trim(),
          etat: _etat,
          siteActuel: _selectedSite ?? '',
          marche: _selectedMarche ?? '',
          dateEnregistrement: now,
          derniereMiseAJour: now,
          enregistrePar: '',
        );
        await _firestoreService.creerMateriel(materiel);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.materiel != null
                  ? 'Matériel mis à jour avec succès'
                  : 'Matériel créé avec succès',
            ),
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
    final isEditing = widget.materiel != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le matériel' : 'Nouveau matériel'),
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
              TextFormField(
                controller: _codeQRController,
                decoration: const InputDecoration(
                  labelText: 'Code QR / Barcode',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le code QR';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _designationController,
                decoration: const InputDecoration(
                  labelText: 'Désignation',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la désignation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numeroSerieController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de série',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _marqueController,
                      decoration: const InputDecoration(
                        labelText: 'Marque',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _modeleController,
                      decoration: const InputDecoration(
                        labelText: 'Modèle',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedSite,
                decoration: const InputDecoration(
                  labelText: 'Site',
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
                  setState(() => _selectedSite = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un site';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedMarche,
                decoration: const InputDecoration(
                  labelText: 'Marché',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                items: _marches.map((marche) {
                  return DropdownMenuItem(
                    value: marche.numero,
                    child: Text('${marche.numero} - ${marche.intitule}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedMarche = value);
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'État du matériel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<EtatMateriel>(
                segments: const [
                  ButtonSegment(
                    value: EtatMateriel.actif,
                    label: Text('Actif'),
                    icon: Icon(Icons.check_circle),
                  ),
                  ButtonSegment(
                    value: EtatMateriel.enPanne,
                    label: Text('En panne'),
                    icon: Icon(Icons.warning),
                  ),
                  ButtonSegment(
                    value: EtatMateriel.perdu,
                    label: Text('Perdu'),
                    icon: Icon(Icons.cancel),
                  ),
                ],
                selected: {_etat},
                onSelectionChanged: (Set<EtatMateriel> selected) {
                  setState(() => _etat = selected.first);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galerie'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              if (_photo != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _photo!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMateriel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing ? 'Mettre à jour' : 'Enregistrer',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
