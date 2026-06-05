import '../../domain/entities/achievement_entity.dart';

/// Merepresentasikan baris dari tabel `achievements` di Supabase.
///
/// Schema Supabase:
///   id              uuid PK
///   name            text NOT NULL
///   description     text
///   badge_icon      text
///   condition_type  text  (study_time | streak | task_done)
///   condition_value integer
class AchievementSupabaseModel {
  final String id;
  final String name;
  final String? description;
  final String? badgeIcon;
  final String? conditionType;
  final int? conditionValue;

  const AchievementSupabaseModel({
    required this.id,
    required this.name,
    this.description,
    this.badgeIcon,
    this.conditionType,
    this.conditionValue,
  });

  factory AchievementSupabaseModel.fromJson(Map<String, dynamic> json) {
    return AchievementSupabaseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      badgeIcon: json['badge_icon'] as String?,
      conditionType: json['condition_type'] as String?,
      conditionValue: (json['condition_value'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (description != null) 'description': description,
    if (badgeIcon != null) 'badge_icon': badgeIcon,
    if (conditionType != null) 'condition_type': conditionType,
    if (conditionValue != null) 'condition_value': conditionValue,
  };

  AchievementEntity toEntity() => AchievementEntity(
    id: id,
    name: name,
    description: description ?? '',
    badgeIcon: badgeIcon ?? 'emoji_events',
    conditionType: conditionType ?? '',
    conditionValue: conditionValue ?? 0,
  );
}

/// Merepresentasikan baris dari tabel `user_achievements` di Supabase.
///
/// Schema Supabase:
///   id              uuid PK
///   user_id         uuid FK → users
///   achievement_id  uuid FK → achievements
///   unlocked_at     timestamptz default now()
class UserAchievementSupabaseModel {
  final String id;
  final String userId;
  final String achievementId;
  final DateTime unlockedAt;

  /// Achievement detail (joined dari tabel achievements)
  final AchievementSupabaseModel? achievement;

  const UserAchievementSupabaseModel({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
    this.achievement,
  });

  factory UserAchievementSupabaseModel.fromJson(Map<String, dynamic> json) {
    AchievementSupabaseModel? achievement;
    if (json['achievements'] != null) {
      achievement = AchievementSupabaseModel.fromJson(
        json['achievements'] as Map<String, dynamic>,
      );
    }

    return UserAchievementSupabaseModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      achievementId: json['achievement_id'] as String,
      unlockedAt: DateTime.parse(json['unlocked_at'] as String),
      achievement: achievement,
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'user_id': userId,
    'achievement_id': achievementId,
  };

  UserAchievementEntity toEntity() => UserAchievementEntity(
    id: id,
    userId: userId,
    achievementId: achievementId,
    unlockedAt: unlockedAt,
    achievement: achievement?.toEntity(),
  );
}
