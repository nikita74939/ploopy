class ProfileStatsEntity {
  final int friendCount;
  final int activityCount;
  final int currentStreak;
  final int longestStreak;

  const ProfileStatsEntity({
    required this.friendCount,
    required this.activityCount,
    required this.currentStreak,
    required this.longestStreak,
  });

  const ProfileStatsEntity.empty()
    : friendCount = 0,
      activityCount = 0,
      currentStreak = 0,
      longestStreak = 0;
}
