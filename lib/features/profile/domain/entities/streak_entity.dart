class ProfileStreakEntity {
  final String? id;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final int freezeUsedThisWeek;

  const ProfileStreakEntity({
    this.id,
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActiveDate,
    required this.freezeUsedThisWeek,
  });

  factory ProfileStreakEntity.defaultFor(String userId) {
    return ProfileStreakEntity(
      userId: userId,
      currentStreak: 0,
      longestStreak: 0,
      freezeUsedThisWeek: 0,
    );
  }
}
