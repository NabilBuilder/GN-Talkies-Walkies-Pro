import 'package:flutter/material.dart';
import '../models/historique_transfert.dart';
import '../services/firestore_service.dart';
import '../l10n/app_localizations.dart';

class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<HistoriqueTransfert>>(
        stream: _firestoreService.getHistoriqueTransferts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${AppLocalizations.of(context)!.error}: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final transferts = snapshot.data!;

          if (transferts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noTransferHistory,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transferts.length,
            itemBuilder: (context, index) {
              final transfert = transferts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transfert.confirme
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    child: Icon(
                      transfert.confirme ? Icons.check_circle : Icons.pending,
                      color: transfert.confirme ? Colors.orange : Colors.green,
                    ),
                  ),
                  title: Text(
                    transfert.materielDesignation,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            transfert.siteOrigine,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.arrow_forward, size: 16),
                          ),
                          Text(
                            transfert.siteDestination,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppLocalizations.of(context)!.reason}: ${transfert.motif}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '${AppLocalizations.of(context)!.date}: ${transfert.dateTransfert.day}/${transfert.dateTransfert.month}/${transfert.dateTransfert.year}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) {
                      final items = <PopupMenuItem<String>>[
                        PopupMenuItem(
                          value: 'details',
                          child: Row(
                            children: [
                              Icon(Icons.info, size: 20),
                              SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.details),
                            ],
                          ),
                        ),
                      ];

                      if (!transfert.confirme) {
                        items.add(
                          PopupMenuItem(
                            value: 'confirmer',
                            child: Row(
                              children: [
                                Icon(Icons.check, size: 20, color: Colors.green),
                                SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.confirmReceipt),
                              ],
                            ),
                          ),
                        );
                      }

                      return items;
                    },
                    onSelected: (value) async {
                      if (value == 'details') {
                        _showDetails(transfert);
                      } else if (value == 'confirmer') {
                        _confirmerTransfert(transfert);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDetails(HistoriqueTransfert transfert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.transferDetails),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(AppLocalizations.of(context)!.material, transfert.materielDesignation),
            _buildDetailRow('Code QR', transfert.codeQR),
            _buildDetailRow(AppLocalizations.of(context)!.siteOrigin, transfert.siteOrigine),
            _buildDetailRow(AppLocalizations.of(context)!.siteDestination, transfert.siteDestination),
            _buildDetailRow(AppLocalizations.of(context)!.transferredBy, transfert.transferePar),
            _buildDetailRow(AppLocalizations.of(context)!.reason, transfert.motif),
            _buildDetailRow(
              AppLocalizations.of(context)!.transferDate,
              '${transfert.dateTransfert.day}/${transfert.dateTransfert.month}/${transfert.dateTransfert.year}',
            ),
            _buildDetailRow(
              AppLocalizations.of(context)!.status,
              transfert.confirme ? AppLocalizations.of(context)!.confirmed : AppLocalizations.of(context)!.pending,
            ),
            if (transfert.confirme) ...[
              _buildDetailRow(AppLocalizations.of(context)!.confirmedBy, transfert.confirmePar),
              _buildDetailRow(
                AppLocalizations.of(context)!.confirmationDate,
                transfert.dateConfirmation != null
                    ? '${transfert.dateConfirmation!.day}/${transfert.dateConfirmation!.month}/${transfert.dateConfirmation!.year}'
                    : '-',
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmerTransfert(HistoriqueTransfert transfert) async {
    try {
      await _firestoreService.confirmerTransfert(transfert.id, '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.transferConfirmed),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
