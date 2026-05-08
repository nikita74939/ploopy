/// Entity untuk achievement sesuai tabel `achievements` di Supabase.
/// id menggunakan String (UUID) bukan int.
class AchievementEntity {
  final String id;         // uuid di Supabase
  final String name;
  final String description;
  final String badgeIcon;        // badge_icon di Supabase
  final String conditionType;    // condition_type: study_time | streak | task_done
  final int conditionValue;      // condition_value

  const AchievementEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.badgeIcon,
    required this.conditionType,
    required this.conditionValue,
  });
}

/// Entity untuk user_achievements sesuai tabel di Supabase.
/// achievementId menggunakan String (UUID).
class UserAchievementEntity {
  final String id;
  final String userId;
  final String achievementId;   // uuid FK ke achievements
  final DateTime unlockedAt;
  final AchievementEntity? achievement;  // joined data

  const UserAchievementEntity({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
    this.achievement,
  });
}