class OcrResult {
  final String id;
  final String title;
  final String extractedText;
  final String? imagePath;
  final int blockCount; // jumlah block teks terdeteksi
  final DateTime createdAt;

  OcrResult({
    required this.id,
    required this.title,
    required this.extractedText,
    this.imagePath,
    required this.blockCount,
    required this.createdAt,
  });

  int get wordCount {
    if (extractedText.trim().isEmpty) return 0;
    return extractedText.trim().split(RegExp(r'\s+')).length;
  }

  int get charCount => extractedText.length;

  String get preview {
    final clean = extractedText.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.length <= 80) return clean;
    return '${clean.substring(0, 80)}...';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'extractedText': extractedText,
        'imagePath': imagePath,
        'blockCount': blockCount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      id: json['id'] as String,
      title: json['title'] as String,
      extractedText: json['extractedText'] as String,
      imagePath: json['imagePath'] as String?,
      blockCount: json['blockCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  OcrResult copyWith({
    String? title,
    String? extractedText,
  }) {
    return OcrResult(
      id: id,
      title: title ?? this.title,
      extractedText: extractedText ?? this.extractedText,
      imagePath: imagePath,
      blockCount: blockCount,
      createdAt: createdAt,
    );
  }
}