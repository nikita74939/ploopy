class ScannedDoc {
  final String id;
  final String title;
  final List<String> imagePaths; // bisa multi-page
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'imagePaths': imagePaths,
        'pdfPath': pdfPath,
        'scannedAt': scannedAt.toIso8601String(),
      };

  factory ScannedDoc.fromJson(Map<String, dynamic> json) {
    return ScannedDoc(
      id: json['id'] as String,
      title: json['title'] as String,
      imagePaths: (json['imagePaths'] as List).map((e) => e as String).toList(),
      pdfPath: json['pdfPath'] as String?,
      scannedAt: DateTime.parse(json['scannedAt'] as String),
    );
  }
}