class Activity {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final String? imageUrl;
  final String? location;
  final double? latitude;
  final double? longitude;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    this.imageUrl,
    this.location,
    this.latitude,
    this.longitude,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  Activity copyWith({
    String? content,
    String? imageUrl,
    String? location,
    double? latitude,
    double? longitude,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
  }) {
    return Activity(
      id: id,
      userId: userId,
      userName: userName,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'content': content,
        'imageUrl': imageUrl,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'likeCount': likeCount,
        'commentCount': commentCount,
        'isLiked': isLiked,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}