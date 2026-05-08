import '../../domain/entities/activity_entity.dart';

/// Represents a row from the `activities` table in Supabase.
/// Images are stored in `activity_images` table (joined).
class ActivityModel {
  final String id;
  final String userId;
  final String text;
  final String? location;
  final String? achievementId;
  final DateTime createdAt;

  // Joined from activity_images
  final List<String> imageUrls;

  // Aggregated / computed
  final int likeCount;
  final bool isLikedByMe;
  final int commentCount;

  // Joined from profiles table
  final String? userName;
  final String? userPhoto;

  const ActivityModel({
    required this.id,
    required this.userId,
    required this.text,
    this.location,
    this.achievementId,
    required this.createdAt,
    this.imageUrls = const [],
    this.likeCount = 0,
    this.isLikedByMe = false,
    this.commentCount = 0,
    this.userName,
    this.userPhoto,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    // activity_images is a nested list returned via Supabase join
    final rawImages = json['activity_images'] as List<dynamic>? ?? [];
    final imageUrls = rawImages.map((e) => e['image_url'] as String).toList();

    return ActivityModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      text: json['text'] as String,
      location: json['location'] as String?,
      achievementId: json['achievement_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      imageUrls: imageUrls,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      userName: json['profiles']?['name'] as String?,
      userPhoto: json['profiles']?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'user_id': userId,
    'text': text,
    if (location != null) 'location': location,
    if (achievementId != null) 'achievement_id': achievementId,
  };

  ActivityEntity toEntity() => ActivityEntity(
    id: id,
    userId: userId,
    text: text,
    location: location,
    achievementId: achievementId,
    imageUrls: imageUrls,
    likeCount: likeCount,
    isLikedByMe: isLikedByMe,
    commentCount: commentCount,
    createdAt: createdAt,
    userName: userName,
    userPhoto: userPhoto,
  );

  ActivityModel copyWith({bool? isLikedByMe, int? likeCount}) => ActivityModel(
    id: id,
    userId: userId,
    text: text,
    location: location,
    achievementId: achievementId,
    createdAt: createdAt,
    imageUrls: imageUrls,
    likeCount: likeCount ?? this.likeCount,
    isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    commentCount: commentCount,
    userName: userName,
    userPhoto: userPhoto,
  );
}
