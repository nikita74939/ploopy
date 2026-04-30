class OcrResult {
  final String id;
  final String title;
  final String extractedText;
  final int wordCount;
  final int blockCount;
  final String imagePath;
  final DateTime createdAt;

  OcrResult({
    required this.id,
    required this.title,
    required this.extractedText,
    required this.wordCount,
    required this.blockCount,
    required this.imagePath,
    required this.createdAt,
  });

  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      id: json['id'] as String,
      title: json['title'] as String,
      extractedText: json['extractedText'] as String,
      wordCount: json['wordCount'] as int,
      blockCount: json['blockCount'] as int,
      imagePath: json['imagePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'extractedText': extractedText,
      'wordCount': wordCount,
      'blockCount': blockCount,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  OcrResult copyWith({
    String? id,
    String? title,
    String? extractedText,
    int? wordCount,
    int? blockCount,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return OcrResult(
      id: id ?? this.id,
      title: title ?? this.title,
      extractedText: extractedText ?? this.extractedText,
      wordCount: wordCount ?? this.wordCount,
      blockCount: blockCount ?? this.blockCount,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}