import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/entities/friendship_entity.dart';
import '../../domain/entities/streak_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/app_settings_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ─── USER ─────────────────────────────────────────────────────────────────

  @override
  Future<UserEntity?> getUserById(String userId) async {
    try {
      // Coba ambil dari backend API dulu.
      final remoteUser = await remoteDataSource.getUserById(userId);
      if (remoteUser != null) {
        // Cache ke Isar
        await localDataSource.updateUser(remoteUser);
        return remoteUser.toEntity();
      }
    } catch (_) {
      // Fallback ke cache lokal jika offline
    }
    final localUser = await localDataSource.getUserById(userId);
    return localUser?.toEntity();
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final model = UserModel.fromEntity(user);
    // Update ke backend API.
    await remoteDataSource.updateUser(model);
    // Update cache lokal
    await localDataSource.updateUser(model);
  }

  // ─── ACHIEVEMENTS ──────────────────────────────────────────────────────────

  @override
  Future<List<AchievementEntity>> getAllAchievements() async {
    final achievements = await remoteDataSource.getAllAchievements();
    return achievements.map((achievement) => achievement.toEntity()).toList();
  }

  @override
  Future<List<UserAchievementEntity>> getUserAchievements(String userId) async {
    final achievements = await remoteDataSource.getUserAchievements(userId);
    return achievements.map((achievement) => achievement.toEntity()).toList();
  }

  @override
  Future<void> unlockAchievement(String userId, String achievementId) async {
    await remoteDataSource.unlockAchievement(userId, achievementId);
  }

  // ─── FRIENDS ───────────────────────────────────────────────────────────────

  @override
  Future<List<ProfileFriendshipEntity>> getFriends(String userId) async {
    final friends = await remoteDataSource.getFriends(userId);
    return friends.map((friend) => friend.toEntity()).toList();
  }

  @override
  Future<ProfileFriendshipEntity> sendFriendRequest(
    String requesterId,
    String addresseeId,
  ) async {
    final friendship = await remoteDataSource.sendFriendRequest(
      requesterId,
      addresseeId,
    );
    return friendship.toEntity();
  }

  @override
  Future<void> acceptFriendRequest(String friendshipId) async {
    await remoteDataSource.acceptFriendRequest(friendshipId);
  }

  @override
  Future<void> removeFriend(String friendshipId) async {
    await remoteDataSource.removeFriend(friendshipId);
  }

  // ─── SETTINGS ──────────────────────────────────────────────────────────────

  @override
  Future<ProfileAppSettingsEntity> getAppSettings(String userId) async {
    final settings = await remoteDataSource.getAppSettings(userId);
    return settings.toEntity();
  }

  @override
  Future<void> upsertAppSettings(ProfileAppSettingsEntity settings) async {
    await remoteDataSource.upsertAppSettings(
      AppSettingsModel.fromEntity(settings),
    );
  }

  // ─── STREAKS ───────────────────────────────────────────────────────────────

  @override
  Future<ProfileStreakEntity> getStreak(String userId) async {
    final streak = await remoteDataSource.getStreak(userId);
    return streak.toEntity();
  }

  @override
  Future<void> upsertStreak(ProfileStreakEntity streak) async {
    await remoteDataSource.upsertStreak(StreakModel.fromEntity(streak));
  }
}
