import 'dart:convert';
import 'dart:io';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../features/scanner/domain/scanned_doc_model.dart';

class ScannerService {
  static const String _storageKey = 'ploopy_scanned_docs';
  static const _uuid = Uuid();

  /// Scan documents pakai ML Kit Document Scanner
  /// Returns list of image paths
  static Future<List<String>?> scanDocuments() async {
    try {
      final images = await CunningDocumentScanner.getPictures(
        noOfPages: 10, // max 10 pages
        isGalleryImportAllowed: true, // allow import from gallery
      );

      if (images == null || images.isEmpty) return null;

      // Copy images ke app storage supaya persistent
      final savedPaths = <String>[];
      final appDir = await getApplicationDocumentsDirectory();
      final scansDir = Directory('${appDir.path}/ploopy_scans');
      if (!await scansDir.exists()) {
        await scansDir.create(recursive: true);
      }

      for (var i = 0; i < images.length; i++) {
        final originalFile = File(images[i]);
        if (await originalFile.exists()) {
          final newName = '${_uuid.v4()}_$i.jpg';
          final newPath = '${scansDir.path}/$newName';
          await originalFile.copy(newPath);
          savedPaths.add(newPath);
        }
      }

      return savedPaths;
    } catch (e) {
      print('❌ Error scanning: $e');
      return null;
    }
  }

  /// Generate PDF dari list of images
  static Future<String?> generatePdf({
    required String title,
    required List<String> imagePaths,
  }) async {
    try {
      final pdf = pw.Document();

      for (final imgPath in imagePaths) {
        final file = File(imgPath);
        if (!await file.exists()) continue;

        final imageBytes = await file.readAsBytes();
        final image = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (context) {
              return pw.Center(
                child: pw.Image(image, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      }

      // Save PDF
      final appDir = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${appDir.path}/ploopy_pdfs');
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }

      final safeTitle = title
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final pdfPath = '${pdfDir.path}/${safeTitle}_$timestamp.pdf';

      final file = File(pdfPath);
      await file.writeAsBytes(await pdf.save());

      return pdfPath;
    } catch (e) {
      print('❌ Error generating PDF: $e');
      return null;
    }
  }

  // ========== Storage Operations ==========

  static Future<List<ScannedDoc>> getAllDocs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr == null || jsonStr.isEmpty) return [];

      final List<dynamic> list = jsonDecode(jsonStr);
      return list
          .map((e) => ScannedDoc.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error loading docs: $e');
      return [];
    }
  }

  static Future<bool> _saveAll(List<ScannedDoc> docs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = docs.map((d) => d.toJson()).toList();
      return await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      print('❌ Error saving docs: $e');
      return false;
    }
  }

  static Future<ScannedDoc?> saveDoc({
    required String title,
    required List<String> imagePaths,
    String? pdfPath,
  }) async {
    try {
      final doc = ScannedDoc(
        id: _uuid.v4(),
        title: title.trim().isEmpty
            ? 'Scan ${DateTime.now().day}/${DateTime.now().month}'
            : title.trim(),
        imagePaths: imagePaths,
        pdfPath: pdfPath,
        scannedAt: DateTime.now(),
      );

      final docs = await getAllDocs();
      docs.insert(0, doc); // newest first
      final saved = await _saveAll(docs);
      return saved ? doc : null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> updateTitle(String id, String newTitle) async {
    final docs = await getAllDocs();
    final index = docs.indexWhere((d) => d.id == id);
    if (index == -1) return false;

    docs[index] = ScannedDoc(
      id: docs[index].id,
      title: newTitle,
      imagePaths: docs[index].imagePaths,
      pdfPath: docs[index].pdfPath,
      scannedAt: docs[index].scannedAt,
    );
    return await _saveAll(docs);
  }

  static Future<bool> deleteDoc(String id) async {
    final docs = await getAllDocs();
    final doc = docs.firstWhere(
      (d) => d.id == id,
      orElse: () => ScannedDoc(
        id: '',
        title: '',
        imagePaths: [],
        scannedAt: DateTime.now(),
      ),
    );

    // Delete files
    for (final imgPath in doc.imagePaths) {
      try {
        final file = File(imgPath);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }

    if (doc.pdfPath != null) {
      try {
        final pdfFile = File(doc.pdfPath!);
        if (await pdfFile.exists()) await pdfFile.delete();
      } catch (_) {}
    }

    docs.removeWhere((d) => d.id == id);
    return await _saveAll(docs);
  }
}