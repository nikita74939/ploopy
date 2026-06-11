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
  static const Uuid _uuid = Uuid();

  static Future<List<String>?> scanDocuments({int noOfPages = 10}) async {
    try {
      final images = await CunningDocumentScanner.getPictures(
        noOfPages: noOfPages,
        isGalleryImportAllowed: true,
      );

      if (images == null || images.isEmpty) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final scansDir = Directory('${appDir.path}/ploopy_scans');

      if (!await scansDir.exists()) {
        await scansDir.create(recursive: true);
      }

      final savedPaths = <String>[];

      for (var i = 0; i < images.length; i++) {
        final originalFile = File(images[i]);

        if (!await originalFile.exists()) continue;

        final fileName = '${_uuid.v4()}_$i.jpg';
        final newPath = '${scansDir.path}/$fileName';

        await originalFile.copy(newPath);
        savedPaths.add(newPath);
      }

      return savedPaths;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> generatePdf({
    required String title,
    required List<String> imagePaths,
  }) async {
    try {
      final pdf = pw.Document();

      for (final imagePath in imagePaths) {
        final file = File(imagePath);

        if (!await file.exists()) continue;

        final imageBytes = await file.readAsBytes();
        final image = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (_) {
              return pw.Center(
                child: pw.Image(
                  image,
                  fit: pw.BoxFit.contain,
                ),
              );
            },
          ),
        );
      }

      final appDir = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${appDir.path}/ploopy_pdfs');

      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }

      final safeTitle = title
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '_');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final pdfPath = '${pdfDir.path}/${safeTitle}_$timestamp.pdf';

      final file = File(pdfPath);
      await file.writeAsBytes(await pdf.save());

      return pdfPath;
    } catch (e) {
      return null;
    }
  }

  static Future<List<ScannedDoc>> getAllDocs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) return [];

      final decoded = jsonDecode(jsonString) as List<dynamic>;

      return decoded
          .map((item) => ScannedDoc.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<ScannedDoc?> getDocById(String id) async {
    final docs = await getAllDocs();

    try {
      return docs.firstWhere((doc) => doc.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> _saveAll(List<ScannedDoc> docs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = docs.map((doc) => doc.toJson()).toList();

      return prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      return false;
    }
  }

  static Future<ScannedDoc?> saveDoc({
    required String title,
    required List<String> imagePaths,
    String? pdfPath,
  }) async {
    try {
      final cleanedTitle = title.trim();

      final doc = ScannedDoc(
        id: _uuid.v4(),
        title: cleanedTitle.isEmpty
            ? 'Scan ${DateTime.now().day}/${DateTime.now().month}'
            : cleanedTitle,
        imagePaths: imagePaths,
        pdfPath: pdfPath,
        scannedAt: DateTime.now(),
      );

      final docs = await getAllDocs();
      docs.insert(0, doc);

      final saved = await _saveAll(docs);
      return saved ? doc : null;
    } catch (e) {
      return null;
    }
  }

  static Future<ScannedDoc?> addPagesToDoc({
    required String id,
    required List<String> newImagePaths,
  }) async {
    if (newImagePaths.isEmpty) return null;

    final docs = await getAllDocs();
    final index = docs.indexWhere((doc) => doc.id == id);

    if (index == -1) return null;

    final oldDoc = docs[index];

    final updatedDoc = oldDoc.copyWith(
      imagePaths: [
        ...oldDoc.imagePaths,
        ...newImagePaths,
      ],
      pdfPath: null,
    );

    docs[index] = updatedDoc;

    final saved = await _saveAll(docs);
    return saved ? updatedDoc : null;
  }

  static Future<bool> updateTitle(String id, String newTitle) async {
    final cleanedTitle = newTitle.trim();

    if (cleanedTitle.isEmpty) return false;

    final docs = await getAllDocs();
    final index = docs.indexWhere((doc) => doc.id == id);

    if (index == -1) return false;

    docs[index] = docs[index].copyWith(
      title: cleanedTitle,
      pdfPath: null,
    );

    return _saveAll(docs);
  }

  static Future<ScannedDoc?> deletePage({
    required String docId,
    required int pageIndex,
  }) async {
    final docs = await getAllDocs();
    final index = docs.indexWhere((doc) => doc.id == docId);

    if (index == -1) return null;

    final doc = docs[index];

    if (pageIndex < 0 || pageIndex >= doc.imagePaths.length) {
      return null;
    }

    final removedPath = doc.imagePaths[pageIndex];
    final updatedPaths = List<String>.from(doc.imagePaths)..removeAt(pageIndex);

    try {
      final file = File(removedPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}

    if (updatedPaths.isEmpty) {
      await deleteDoc(docId);
      return null;
    }

    final updatedDoc = doc.copyWith(
      imagePaths: updatedPaths,
      pdfPath: null,
    );

    docs[index] = updatedDoc;

    final saved = await _saveAll(docs);
    return saved ? updatedDoc : null;
  }

  static Future<bool> deleteDoc(String id) async {
    final docs = await getAllDocs();
    final index = docs.indexWhere((doc) => doc.id == id);

    if (index == -1) return false;

    final doc = docs[index];

    for (final imagePath in doc.imagePaths) {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }

    if (doc.pdfPath != null) {
      try {
        final pdfFile = File(doc.pdfPath!);
        if (await pdfFile.exists()) {
          await pdfFile.delete();
        }
      } catch (_) {}
    }

    docs.removeAt(index);

    return _saveAll(docs);
  }
}