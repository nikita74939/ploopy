import '../../domain/entities/activity_comment_entity.dart';

/// Represents a row from the `activity_comments` table in Supabase.
class ActivityCommentModel {
  final String id;
  final String activityId;
  final String userId;
  final String content;
  final DateTime createdAt;

  // Joined from profiles table
  final String? userName;
  final String? userPhoto;

  const ActivityCommentModel({
    required this.id,
    required this.activityId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.userName,
    this.userPhoto,
  });

  factory ActivityCommentModel.fromJson(Map<String, dynamic> json) {
    return ActivityCommentModel(
      id: json['id'] as String,
      activityId: json['activity_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: json['profiles']?['name'] as String?,
      userPhoto: json['profiles']?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'activity_id': activityId,
    'user_id': userId,
    'content': content,
  };

  ActivityCommentEntity toEntity() => ActivityCommentEntity(
    id: id,
    activityId: activityId,
    userId: userId,
    content: content,
    createdAt: createdAt,
    userName: userName,
    userPhoto: userPhoto,
  );
}
