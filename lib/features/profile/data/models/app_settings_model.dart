import '../../domain/entities/app_settings_entity.dart';
import '../../domain/entities/streak_entity.dart';

/// Merepresentasikan baris dari tabel `app_settings` di Supabase.
///
/// Schema Supabase:
///   id               uuid PK
///   user_id          uuid UNIQUE FK → users
///   dark_mode        boolean default false
///   language         text default 'id'
///   notif_enabled    boolean default true
///   app_lock_enabled boolean default false
class AppSettingsModel {
  final String? id;
  final String userId;
  final bool darkMode;
  final String language;
  final bool notifEnabled;
  final bool appLockEnabled;

  const AppSettingsModel({
    this.id,
    required this.userId,
    this.darkMode = false,
    this.language = 'id',
    this.notifEnabled = true,
    this.appLockEnabled = false,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      darkMode: json['dark_mode'] as bool? ?? false,
      language: json['language'] as String? ?? 'id',
      notifEnabled: json['notif_enabled'] as bool? ?? true,
      appLockEnabled: json['app_lock_enabled'] as bool? ?? false,
    );
  }

  /// Default settings untuk user baru
  factory AppSettingsModel.defaultFor(String userId) {
    return AppSettingsModel(
      userId: userId,
      darkMode: false,
      language: 'id',
      notifEnabled: true,
      appLockEnabled: false,
    );
  }

  factory AppSettingsModel.fromEntity(ProfileAppSettingsEntity entity) {
    return AppSettingsModel(
      id: entity.id,
      userId: entity.userId,
      darkMode: entity.darkMode,
      language: entity.language,
      notifEnabled: entity.notifEnabled,
      appLockEnabled: entity.appLockEnabled,
    );
  }

  Map<String, dynamic> toUpsertJson() => {
    'user_id': userId,
    'dark_mode': darkMode,
    'language': language,
    'notif_enabled': notifEnabled,
    'app_lock_enabled': appLockEnabled,
  };

  AppSettingsModel copyWith({
    bool? darkMode,
    String? language,
    bool? notifEnabled,
    bool? appLockEnabled,
  }) {
    return AppSettingsModel(
      id: id,
      userId: userId,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      notifEnabled: notifEnabled ?? this.notifEnabled,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    );
  }

  ProfileAppSettingsEntity toEntity() => ProfileAppSettingsEntity(
    id: id,
    userId: userId,
    darkMode: darkMode,
    language: language,
    notifEnabled: notifEnabled,
    appLockEnabled: appLockEnabled,
  );
}

/// Merepresentasikan baris dari tabel `streaks` di Supabase.
///
/// Schema Supabase:
///   id                    uuid PK
///   user_id               uuid UNIQUE FK → users
///   current_streak        integer default 0
///   longest_streak        integer default 0
///   last_active_date      date
///   freeze_used_this_week integer default 0
class StreakModel {
  final String? id;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final int freezeUsedThisWeek;

  const StreakModel({
    this.id,
    required this.userId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.freezeUsedThisWeek = 0,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      lastActiveDate: json['last_active_date'] != null
          ? DateTime.parse(json['last_active_date'] as String)
          : null,
      freezeUsedThisWeek: (json['freeze_used_this_week'] as num?)?.toInt() ?? 0,
    );
  }

  factory StreakModel.defaultFor(String userId) {
    return StreakModel(
      userId: userId,
      currentStreak: 0,
      longestStreak: 0,
      freezeUsedThisWeek: 0,
    );
  }

  factory StreakModel.fromEntity(ProfileStreakEntity entity) {
    return StreakModel(
      id: entity.id,
      userId: entity.userId,
      currentStreak: entity.currentStreak,
      longestStreak: entity.longestStreak,
      lastActiveDate: entity.lastActiveDate,
      freezeUsedThisWeek: entity.freezeUsedThisWeek,
    );
  }

  Map<String, dynamic> toUpsertJson() => {
    'user_id': userId,
    'current_streak': currentStreak,
    'longest_streak': longestStreak,
    if (lastActiveDate != null)
      'last_active_date': lastActiveDate!.toIso8601String().split('T')[0],
    'freeze_used_this_week': freezeUsedThisWeek,
  };

  ProfileStreakEntity toEntity() => ProfileStreakEntity(
    id: id,
    userId: userId,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    lastActiveDate: lastActiveDate,
    freezeUsedThisWeek: freezeUsedThisWeek,
  );
}
