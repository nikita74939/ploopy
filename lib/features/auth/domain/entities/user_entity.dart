class UserEntity {
  final int id;
  final String name;
  final String email;
  final String? bio;
  final String? avatarUrl;
  final DateTime joinedAt;
  final bool biometricEnabled;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.avatarUrl,
    required this.joinedAt,
    required this.biometricEnabled,
  });
}
