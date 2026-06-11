class ProfileAppSettingsEntity {
  final String? id;
  final String userId;
  final bool darkMode;
  final String language;
  final bool notifEnabled;
  final bool appLockEnabled;

  const ProfileAppSettingsEntity({
    this.id,
    required this.userId,
    required this.darkMode,
    required this.language,
    required this.notifEnabled,
    required this.appLockEnabled,
  });

  factory ProfileAppSettingsEntity.defaultFor(String userId) {
    return ProfileAppSettingsEntity(
      userId: userId,
      darkMode: false,
      language: 'id',
      notifEnabled: true,
      appLockEnabled: false,
    );
  }

  ProfileAppSettingsEntity copyWith({
    bool? darkMode,
    String? language,
    bool? notifEnabled,
    bool? appLockEnabled,
  }) {
    return ProfileAppSettingsEntity(
      id: id,
      userId: userId,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      notifEnabled: notifEnabled ?? this.notifEnabled,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    );
  }
}
