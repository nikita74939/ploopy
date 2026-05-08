class ActivityCommentEntity {
  final String id;
  final String activityId;
  final String userId;
  final String content;
  final DateTime createdAt;

  // Denormalized fields (joined from profiles)
  final String? userName;
  final String? userPhoto;

  const ActivityCommentEntity({
    required this.id,
    required this.activityId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.userName,
    this.userPhoto,
  });
}