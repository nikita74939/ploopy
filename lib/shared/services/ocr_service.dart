import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../features/ocr/domain/ocr_result_model.dart';

class OcrService {
  static final ImagePicker _picker = ImagePicker();
  static final TextRecognizer _textRecognizer = TextRecognizer();
  static const _uuid = Uuid();

  static Future<List<OcrResult>> getAll() async {
    try {
      final dir = await _getResultDir();
      if (!dir.existsSync()) return [];

      final files = dir.listSync().where((f) => f.path.endsWith('.json'));
      final results = <OcrResult>[];

      for (final file in files) {
        final jsonFile = File(file.path);
        if (jsonFile.existsSync()) {
          final data = jsonFile.readAsStringSync();
          final json = Map<String, dynamic>.from(
            Uri.splitQueryString(data).map(
              (k, v) => MapEntry(k, _decodeValue(v)),
            ),
          );
          results.add(OcrResult.fromJson(json));
        }
      }

      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return results;
    } catch (e) {
      return [];
    }
  }

  static Future<String?> pickFromCamera() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 2000,
        maxHeight: 3000,
      );
      return image?.path;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> pickFromGallery() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 2000,
        maxHeight: 3000,
      );
      return image?.path;
    } catch (e) {
      return null;
    }
  }

  static Future<OcrResult?> extractText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognized = await _textRecognizer.processImage(inputImage);

      final text = recognized.text.trim();
      final blocks = recognized.blocks;

      final words = text.isEmpty
          ? 0
          : text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

      return OcrResult(
        id: _uuid.v4(),
        title: 'OCR',
        extractedText: text,
        wordCount: words,
        blockCount: blocks.length,
        imagePath: imagePath,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<OcrResult?> save({
    required String title,
    required String extractedText,
    required int blockCount,
    required String imagePath,
  }) async {
    try {
      final id = _uuid.v4();
      final words = extractedText.isEmpty
          ? 0
          : extractedText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

      final result = OcrResult(
        id: id,
        title: title,
        extractedText: extractedText,
        wordCount: words,
        blockCount: blockCount,
        imagePath: imagePath,
        createdAt: DateTime.now(),
      );

      final dir = await _getResultDir();
      final jsonFile = File('${dir.path}/$id.json');
      await jsonFile.writeAsString(_resultToQuery(result));

      return result;
    } catch (e) {
      return null;
    }
  }

  static Future<void> delete(String id) async {
    try {
      final dir = await _getResultDir();
      final jsonFile = File('${dir.path}/$id.json');

      if (jsonFile.existsSync()) {
        final data = jsonFile.readAsStringSync();
        final json = Map<String, dynamic>.from(
          Uri.splitQueryString(data).map(
            (k, v) => MapEntry(k, _decodeValue(v)),
          ),
        );
        final result = OcrResult.fromJson(json);

        final imgFile = File(result.imagePath);
        if (imgFile.existsSync()) await imgFile.delete();

        await jsonFile.delete();
      }
    } catch (e) {
      // silent fail
    }
  }

  static Future<void> update(OcrResult result) async {
    try {
      final dir = await _getResultDir();
      final jsonFile = File('${dir.path}/${result.id}.json');
      await jsonFile.writeAsString(_resultToQuery(result));
    } catch (e) {
      // silent fail
    }
  }

  static Future<Directory> _getResultDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final resultDir = Directory('${appDir.path}/ocr/results');
    if (!resultDir.existsSync()) resultDir.createSync(recursive: true);
    return resultDir;
  }

  static String _resultToQuery(OcrResult result) {
    return 'id=${result.id}'
        '&title=${Uri.encodeComponent(result.title)}'
        '&extractedText=${Uri.encodeComponent(result.extractedText)}'
        '&wordCount=${result.wordCount}'
        '&blockCount=${result.blockCount}'
        '&imagePath=${Uri.encodeComponent(result.imagePath)}'
        '&createdAt=${result.createdAt.toIso8601String()}';
  }

  static dynamic _decodeValue(String value) {
    try {
      return int.tryParse(value);
    } catch (_) {}
    try {
      return double.tryParse(value);
    } catch (_) {}
    return Uri.decodeComponent(value);
  }
}