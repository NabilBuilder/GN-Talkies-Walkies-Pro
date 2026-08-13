import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/materiel.dart';
import '../models/historique_transfert.dart';

class ExportService {
  Future<String> _getDirectory(String subfolder) async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        throw Exception('Permission de stockage requise');
      }
      final directory = Directory('/storage/emulated/0/Download/$subfolder');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory.path;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/$subfolder');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      return exportDir.path;
    }
  }

  Future<String> exporterMaterielsExcel(List<Materiel> materiels) async {
    final excel = Excel.createExcel();
    final sheet = excel['Matériels'];

    excel.delete('Sheet1');

    final headers = [
      'Code QR',
      'Désignation',
      'N° Série',
      'Marque',
      'Modèle',
      'État',
      'Site Actuel',
      'Marché',
      'Date Enregistrement',
      'Dernière MAJ',
    ];

    for (var i = 0; i < headers.length; i++) {
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        TextCellValue(headers[i]),
        cellStyle: CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#4CAF50'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        ),
      );
    }

    for (var i = 0; i < materiels.length; i++) {
      final m = materiels[i];
      final rowData = [
        m.codeQR,
        m.designation,
        m.numeroSerie,
        m.marque,
        m.modele,
        _etatToString(m.etat),
        m.siteActuel,
        m.marche,
        '${m.dateEnregistrement.day}/${m.dateEnregistrement.month}/${m.dateEnregistrement.year}',
        '${m.derniereMiseAJour.day}/${m.derniereMiseAJour.month}/${m.derniereMiseAJour.year}',
      ];

      for (var j = 0; j < rowData.length; j++) {
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1),
          TextCellValue(rowData[j]),
        );
      }
    }

    final dirPath = await _getDirectory('Exports_Materiel');
    final now = DateTime.now();
    final fileName = 'materiels_${now.day}${now.month}${now.year}_${now.hour}${now.minute}.xlsx';
    final filePath = '$dirPath/$fileName';

    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }

    return filePath;
  }

  Future<String> exporterTransfertsExcel(List<HistoriqueTransfert> transferts) async {
    final excel = Excel.createExcel();
    final sheet = excel['Historique Transferts'];

    excel.delete('Sheet1');

    final headers = [
      'Code QR',
      'Désignation',
      'Site Origine',
      'Site Destination',
      'Transféré par',
      'Motif',
      'Date Transfert',
      'Confirmé',
    ];

    for (var i = 0; i < headers.length; i++) {
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        TextCellValue(headers[i]),
        cellStyle: CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#2196F3'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        ),
      );
    }

    for (var i = 0; i < transferts.length; i++) {
      final t = transferts[i];
      final rowData = [
        t.codeQR,
        t.materielDesignation,
        t.siteOrigine,
        t.siteDestination,
        t.transferePar,
        t.motif,
        '${t.dateTransfert.day}/${t.dateTransfert.month}/${t.dateTransfert.year}',
        t.confirme ? 'Oui' : 'Non',
      ];

      for (var j = 0; j < rowData.length; j++) {
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1),
          TextCellValue(rowData[j]),
        );
      }
    }

    final dirPath = await _getDirectory('Exports_Materiel');
    final now = DateTime.now();
    final fileName = 'transferts_${now.day}${now.month}${now.year}_${now.hour}${now.minute}.xlsx';
    final filePath = '$dirPath/$fileName';

    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }

    return filePath;
  }

  Future<String> exporterMaterielsPDF(List<Materiel> materiels) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        header: (context) => pw.Header(
          child: pw.Text(
            'Liste des Matériels',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Text(
            'Création & Développement Boukhoulkhal Nabil',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: [
              'Code QR',
              'Désignation',
              'N° Série',
              'État',
              'Site',
              'Marché',
            ],
            data: materiels.map((m) => [
              m.codeQR,
              m.designation,
              m.numeroSerie,
              _etatToString(m.etat),
              m.siteActuel,
              m.marche,
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.green300,
            ),
          ),
        ],
      ),
    );

    final dirPath = await _getDirectory('Exports_Materiel');
    final now = DateTime.now();
    final fileName = 'materiels_${now.day}${now.month}${now.year}_${now.hour}${now.minute}.pdf';
    final filePath = '$dirPath/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  Future<String> exporterTransfertsPDF(List<HistoriqueTransfert> transferts) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        header: (context) => pw.Header(
          child: pw.Text(
            'Historique des Transferts',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Text(
            'Création & Développement Boukhoulkhal Nabil',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: [
              'Code QR',
              'Désignation',
              'Origine',
              'Destination',
              'Par',
              'Motif',
              'Date',
            ],
            data: transferts.map((t) => [
              t.codeQR,
              t.materielDesignation,
              t.siteOrigine,
              t.siteDestination,
              t.transferePar,
              t.motif,
              '${t.dateTransfert.day}/${t.dateTransfert.month}/${t.dateTransfert.year}',
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blue300,
            ),
          ),
        ],
      ),
    );

    final dirPath = await _getDirectory('Exports_Materiel');
    final now = DateTime.now();
    final fileName = 'transferts_${now.day}${now.month}${now.year}_${now.hour}${now.minute}.pdf';
    final filePath = '$dirPath/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  String _etatToString(EtatMateriel etat) {
    switch (etat) {
      case EtatMateriel.actif:
        return 'Actif';
      case EtatMateriel.enPanne:
        return 'En panne';
      case EtatMateriel.perdu:
        return 'Perdu';
    }
  }
}
