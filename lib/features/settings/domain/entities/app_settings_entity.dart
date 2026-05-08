class AppSettingsEntity {
  final bool darkMode;
  final String language;
  final bool notifEnabled;
  final bool appLockEnabled;

  const AppSettingsEntity({
    required this.darkMode,
    required this.language,
    required this.notifEnabled,
    required this.appLockEnabled,
  });

  AppSettingsEntity copyWith({
    bool? darkMode,
    String? language,
    bool? notifEnabled,
    bool? appLockEnabled,
  }) =>
      AppSettingsEntity(
        darkMode: darkMode ?? this.darkMode,
        language: language ?? this.language,
        notifEnabled: notifEnabled ?? this.notifEnabled,
        appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      );
}
