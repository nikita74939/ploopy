class ActivityEntity {
  final String id;
  final String userId;
  final String text;
  final String? location;
  final String? achievementId;
  final List<String> imageUrls;
  final int likeCount;
  final bool isLikedByMe;
  final int commentCount;
  final DateTime createdAt;

  // Denormalized fields (joined from profiles)
  final String? userName;
  final String? userPhoto;

  const ActivityEntity({
    required this.id,
    required this.userId,
    required this.text,
    this.location,
    this.achievementId,
    required this.imageUrls,
    required this.likeCount,
    required this.isLikedByMe,
    required this.commentCount,
    required this.createdAt,
    this.userName,
    this.userPhoto,
  });
}