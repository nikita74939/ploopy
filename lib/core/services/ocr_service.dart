import 'dart:convert';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../features/ocr/domain/ocr_result_model.dart';

class OcrService {
  static const String _storageKey = 'ploopy_ocr_results';
  static const _uuid = Uuid();
  static final _picker = ImagePicker();

  /// Pick image dari camera
  static Future<String?> pickFromCamera() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 90,
      );
      if (image == null) return null;

      return await _copyToAppStorage(image.path);
    } catch (e) {
      print('❌ Camera error: $e');
      return null;
    }
  }

  /// Pick image dari gallery
  static Future<String?> pickFromGallery() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 90,
      );
      if (image == null) return null;

      return await _copyToAppStorage(image.path);
    } catch (e) {
      print('❌ Gallery error: $e');
      return null;
    }
  }

  /// Copy image ke app storage supaya persistent
  static Future<String?> _copyToAppStorage(String sourcePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final ocrDir = Directory('${appDir.path}/ploopy_ocr');
      if (!await ocrDir.exists()) {
        await ocrDir.create(recursive: true);
      }

      final fileName = '${_uuid.v4()}.jpg';
      final newPath = '${ocrDir.path}/$fileName';

      final originalFile = File(sourcePath);
      await originalFile.copy(newPath);

      return newPath;
    } catch (e) {
      print('❌ Copy error: $e');
      return null;
    }
  }

  /// Extract text dari image menggunakan ML Kit
  static Future<({String text, int blockCount})?> extractText(
    String imagePath,
  ) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Gabungkan semua block dengan newline
      final text = recognizedText.text;
      final blockCount = recognizedText.blocks.length;

      return (text: text, blockCount: blockCount);
    } catch (e) {
      print('❌ OCR error: $e');
      return null;
    } finally {
      await textRecognizer.close();
    }
  }

  // ========== Storage ==========

  static Future<List<OcrResult>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr == null || jsonStr.isEmpty) return [];

      final List<dynamic> list = jsonDecode(jsonStr);
      return list
          .map((e) => OcrResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Load error: $e');
      return [];
    }
  }

  static Future<bool> _saveAll(List<OcrResult> results) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = results.map((r) => r.toJson()).toList();
      return await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      print('❌ Save error: $e');
      return false;
    }
  }

  static Future<OcrResult?> save({
    required String title,
    required String extractedText,
    required int blockCount,
    String? imagePath,
  }) async {
    try {
      final result = OcrResult(
        id: _uuid.v4(),
        title: title.trim().isEmpty
            ? 'OCR ${DateTime.now().day}/${DateTime.now().month}'
            : title.trim(),
        extractedText: extractedText,
        imagePath: imagePath,
        blockCount: blockCount,
        createdAt: DateTime.now(),
      );

      final list = await getAll();
      list.insert(0, result);
      final saved = await _saveAll(list);
      return saved ? result : null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> update(OcrResult result) async {
    final list = await getAll();
    final index = list.indexWhere((r) => r.id == result.id);
    if (index == -1) return false;
    list[index] = result;
    return await _saveAll(list);
  }

  static Future<bool> delete(String id) async {
    final list = await getAll();
    final doc = list.firstWhere(
      (r) => r.id == id,
      orElse: () => OcrResult(
        id: '',
        title: '',
        extractedText: '',
        blockCount: 0,
        createdAt: DateTime.now(),
      ),
    );

    // Delete image file
    if (doc.imagePath != null) {
      try {
        final file = File(doc.imagePath!);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }

    list.removeWhere((r) => r.id == id);
    return await _saveAll(list);
  }
}