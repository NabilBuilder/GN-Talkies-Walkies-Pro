import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/firestore_service.dart';
import 'materiel_form_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController? cameraController;
  final _manualController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isProcessing = false;
  bool _showManualInput = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      cameraController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
      );
      await cameraController!.start();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _showManualInput = true;
        });
      }
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    _manualController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null) {
        _processCode(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _processCode(String code) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final materiel = await _firestoreService.getMaterielByCodeQR(code);

      if (materiel != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MaterielFormScreen(materiel: materiel),
          ),
        ).then((_) => setState(() => _isProcessing = false));
      } else if (mounted) {
        _showNotFoundDialog(code);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showNotFoundDialog(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Matériel non trouvé'),
        content: Text('Aucun matériel trouvé avec le code: $code'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MaterielFormScreen(
                    materiel: null,
                    codeQR: code,
                  ),
                ),
              );
            },
            child: const Text('Créer'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    ).then((_) => setState(() => _isProcessing = false));
  }

  void _searchManually() {
    final code = _manualController.text.trim();
    if (code.isNotEmpty) {
      _processCode(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: _showManualInput ? 0 : 4,
            child: _showManualInput
                ? const SizedBox.shrink()
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isCameraInitialized && cameraController != null)
                        MobileScanner(
                          controller: cameraController!,
                          onDetect: _onDetect,
                        )
                      else
                        const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF1B5E20),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      if (_isProcessing)
                        const Positioned(
                          bottom: 20,
                          child: CircularProgressIndicator(
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                    ],
                  ),
          ),
          Expanded(
            flex: _showManualInput ? 1 : 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_showManualInput) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _manualController,
                            decoration: InputDecoration(
                              hintText: 'Saisir le code QR ou barcode',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.qr_code),
                            ),
                            onSubmitted: (_) => _searchManually(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _searchManually,
                          icon: const Icon(Icons.search),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showManualInput = !_showManualInput;
                          });
                          if (_showManualInput) {
                            cameraController?.stop();
                          } else {
                            cameraController?.start();
                          }
                        },
                        icon: Icon(
                          _showManualInput ? Icons.camera_alt : Icons.keyboard,
                        ),
                        label: Text(
                          _showManualInput ? 'Scanner' : 'Saisie manuelle',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Scannez un QR Code ou barcode pour identifier le matériel',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
