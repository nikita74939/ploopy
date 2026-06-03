class UserEntity {
  final int id;
  final String userId;
  final String name;
  final String email;
  final String? bio;
  final String? avatarUrl;
  final DateTime joinedAt;
  final bool biometricEnabled;
  final int streak;
  final int longestStreak;
  final int totalStudyMinutes;
  final int totalTasksCompleted;
  final bool appLockEnabled;

  const UserEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.bio,
    this.avatarUrl,
    required this.joinedAt,
    required this.biometricEnabled,
    required this.streak,
    required this.longestStreak,
    required this.totalStudyMinutes,
    required this.totalTasksCompleted,
    required this.appLockEnabled,
  });
}
