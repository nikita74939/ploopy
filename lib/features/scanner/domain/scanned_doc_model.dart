class ScannedDoc {
  final String id;
  final String title;
  final List<String> imagePaths;
  final String? pdfPath;
  final DateTime scannedAt;

  ScannedDoc({
    required this.id,
    required this.title,
    required this.imagePaths,
    this.pdfPath,
    required this.scannedAt,
  });

  int get pageCount => imagePaths.length;

  factory ScannedDoc.fromJson(Map<String, dynamic> json) {
    return ScannedDoc(
      id: json['id'] as String,
      title: json['title'] as String,
      imagePaths: List<String>.from(json['imagePaths'] as List),
      pdfPath: json['pdfPath'] as String?,
      scannedAt: DateTime.parse(json['scannedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imagePaths': imagePaths,
      'pdfPath': pdfPath,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }

  ScannedDoc copyWith({
    String? id,
    String? title,
    List<String>? imagePaths,
    String? pdfPath,
    DateTime? scannedAt,
  }) {
    return ScannedDoc(
      id: id ?? this.id,
      title: title ?? this.title,
      imagePaths: imagePaths ?? this.imagePaths,
      pdfPath: pdfPath ?? this.pdfPath,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }
}