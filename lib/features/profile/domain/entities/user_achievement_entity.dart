class UserAchievementEntity {
  final int id;
  final String userId;
  final String achievementId;
  final DateTime unlockedAt;

  const UserAchievementEntity({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
  });
}
