class StreakEntity {
  final int id;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActiveDate;
  final int freezeUsedThisWeek;

  const StreakEntity({
    required this.id,
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActiveDate,
    required this.freezeUsedThisWeek,
  });
}
