// models/scanned_doc_isar_model.dart
import 'package:isar/isar.dart';

part 'scanned_doc_isar_model.g.dart';

@Collection()
class ScannedDocIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String docId;

  late String title;
  late List<String> imagePaths;

  String? pdfPath;
  String? extractedText;
  String? ocrLanguage;

  late DateTime scannedAt;
  late DateTime updatedAt;

  // ✅ Semua parameter required harus sesuai type property
  ScannedDocIsar({
    required this.docId,
    required this.title,
    required this.imagePaths,
    this.pdfPath,
    this.extractedText,
    this.ocrLanguage,
    required this.scannedAt,
    required DateTime updatedAt, // ← Change from DateTime? to required DateTime
    // ignore: dead_null_aware_expression
  }) : updatedAt = updatedAt ?? scannedAt; // default di initializer list

  // Constructor kosong untuk Isar internal
  ScannedDocIsar.empty();

  ScannedDocIsar copyWith({
    String? docId,
    String? title,
    List<String>? imagePaths,
    String? pdfPath,
    String? extractedText,
    String? ocrLanguage,
    DateTime? scannedAt,
    DateTime? updatedAt,
  }) {
    return ScannedDocIsar(
      docId: docId ?? this.docId,
      title: title ?? this.title,
      imagePaths: imagePaths ?? this.imagePaths,
      pdfPath: pdfPath ?? this.pdfPath,
      extractedText: extractedText ?? this.extractedText,
      ocrLanguage: ocrLanguage ?? this.ocrLanguage,
      scannedAt: scannedAt ?? this.scannedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'docId': docId,
    'title': title,
    'imagePaths': imagePaths,
    'pdfPath': pdfPath,
    'extractedText': extractedText,
    'ocrLanguage': ocrLanguage,
    'scannedAt': scannedAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  static ScannedDocIsar fromJson(Map<String, dynamic> json) {
    return ScannedDocIsar(
      docId: json['docId'] as String,
      title: json['title'] as String,
      imagePaths: (json['imagePaths'] as List).cast<String>(),
      pdfPath: json['pdfPath'] as String?,
      extractedText: json['extractedText'] as String?,
      ocrLanguage: json['ocrLanguage'] as String?,
      scannedAt:
          json['scannedAt'] != null
              ? DateTime.parse(json['scannedAt'] as String)
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
    );
  }
}
