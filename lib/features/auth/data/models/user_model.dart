import 'package:isar/isar.dart';

import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@collection
class UserModel {
  Id get id => fastHash(userId);

  /// UUID dari Supabase auth.users (kolom `id` di tabel public.users)
  @Index(unique: true, replace: true)
  late String userId;

  @Index(unique: true)
  late String email;

  late String name;

  /// password_hash tidak disimpan lokal — Supabase yang mengelola
  String? bio;
  String? avatarUrl; // avatar_url di Supabase
  late DateTime joinedAt; // joined_at di Supabase
  bool biometricEnabled = false;

  // Kolom lokal (tidak ada di Supabase, hanya di Isar)
  int streak = 0;
  int longestStreak = 0;
  int totalStudyMinutes = 0;
  int totalTasksCompleted = 0;
  bool appLockEnabled = false;

  UserModel();

  /// Buat UserModel dari response Supabase
  factory UserModel.fromSupabase(Map<String, dynamic> data) {
    return UserModel()
      ..userId = data['id'] as String
      ..email = data['email'] as String
      ..name = data['name'] as String
      ..bio = data['bio'] as String?
      ..avatarUrl = data['avatar_url'] as String?
      ..joinedAt = DateTime.parse(data['joined_at'] as String)
      ..biometricEnabled = (data['biometric_enabled'] as bool?) ?? false
      ..streak = 0
      ..longestStreak = 0
      ..totalStudyMinutes = 0
      ..totalTasksCompleted = 0
      ..appLockEnabled = false;
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel()
      ..userId = entity.userId
      ..email = entity.email
      ..name = entity.name
      ..bio = entity.bio
      ..avatarUrl = entity.avatarUrl
      ..joinedAt = entity.joinedAt
      ..biometricEnabled = entity.biometricEnabled
      ..streak = entity.streak
      ..longestStreak = entity.longestStreak
      ..totalStudyMinutes = entity.totalStudyMinutes
      ..totalTasksCompleted = entity.totalTasksCompleted
      ..appLockEnabled = entity.appLockEnabled;
  }

  /// Konversi ke Map untuk update ke Supabase
  Map<String, dynamic> toSupabase() {
    return {
      'id': userId,
      'email': email,
      'name': name,
      'bio': bio,
      'avatar_url': avatarUrl,
      'joined_at': joinedAt.toIso8601String(),
      'biometric_enabled': biometricEnabled,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      userId: userId,
      name: name,
      email: email,
      bio: bio,
      avatarUrl: avatarUrl,
      joinedAt: joinedAt,
      biometricEnabled: biometricEnabled,
      streak: streak,
      longestStreak: longestStreak,
      totalStudyMinutes: totalStudyMinutes,
      totalTasksCompleted: totalTasksCompleted,
      appLockEnabled: appLockEnabled,
    );
  }
}

int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    var codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}
