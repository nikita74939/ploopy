import '../../domain/entities/app_settings_entity.dart';

class AppSettingsModel {
  final bool darkMode;
  final String language;
  final bool notifEnabled;
  final bool appLockEnabled;

  const AppSettingsModel({
    required this.darkMode,
    required this.language,
    required this.notifEnabled,
    required this.appLockEnabled,
  });

  AppSettingsEntity toEntity() => AppSettingsEntity(
        darkMode: darkMode,
        language: language,
        notifEnabled: notifEnabled,
        appLockEnabled: appLockEnabled,
      );

  static AppSettingsModel fromEntity(AppSettingsEntity e) => AppSettingsModel(
        darkMode: e.darkMode,
        language: e.language,
        notifEnabled: e.notifEnabled,
        appLockEnabled: e.appLockEnabled,
      );

  // SharedPreferences stores each key separately, this is a convenience
  Map<String, dynamic> toMap() => {
        'dark_mode': darkMode,
        'language': language,
        'notif_enabled': notifEnabled,
        'app_lock_enabled': appLockEnabled,
      };

  factory AppSettingsModel.defaults() => const AppSettingsModel(
        darkMode: false,
        language: 'id',
        notifEnabled: true,
        appLockEnabled: false,
      );
}
