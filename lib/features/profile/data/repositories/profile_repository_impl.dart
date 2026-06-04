import '../../../auth/data/models/user_model.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/achievement_supabase_model.dart';
import '../models/app_settings_model.dart';
import '../models/friendship_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ─── USER ─────────────────────────────────────────────────────────────────

  @override
  Future<UserModel?> getUserById(String userId) async {
    try {
      // Coba ambil dari backend API dulu.
      final remoteUser = await remoteDataSource.getUserById(userId);
      if (remoteUser != null) {
        // Cache ke Isar
        await localDataSource.updateUser(remoteUser);
        return remoteUser;
      }
    } catch (_) {
      // Fallback ke cache lokal jika offline
    }
    return await localDataSource.getUserById(userId);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    // Update ke backend API.
    await remoteDataSource.updateUser(user);
    // Update cache lokal
    await localDataSource.updateUser(user);
  }

  // ─── ACHIEVEMENTS ──────────────────────────────────────────────────────────

  @override
  Future<List<AchievementSupabaseModel>> getAllAchievements() async {
    return await remoteDataSource.getAllAchievements();
  }

  @override
  Future<List<UserAchievementSupabaseModel>> getUserAchievements(
    String userId,
  ) async {
    return await remoteDataSource.getUserAchievements(userId);
  }

  @override
  Future<void> unlockAchievement(String userId, String achievementId) async {
    await remoteDataSource.unlockAchievement(userId, achievementId);
  }

  // ─── FRIENDS ───────────────────────────────────────────────────────────────

  @override
  Future<List<FriendshipModel>> getFriends(String userId) async {
    return await remoteDataSource.getFriends(userId);
  }

  @override
  Future<FriendshipModel> sendFriendRequest(
    String requesterId,
    String addresseeId,
  ) async {
    return await remoteDataSource.sendFriendRequest(requesterId, addresseeId);
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
  Future<AppSettingsModel> getAppSettings(String userId) async {
    return await remoteDataSource.getAppSettings(userId);
  }

  @override
  Future<void> upsertAppSettings(AppSettingsModel settings) async {
    await remoteDataSource.upsertAppSettings(settings);
  }

  // ─── STREAKS ───────────────────────────────────────────────────────────────

  @override
  Future<StreakModel> getStreak(String userId) async {
    return await remoteDataSource.getStreak(userId);
  }

  @override
  Future<void> upsertStreak(StreakModel streak) async {
    await remoteDataSource.upsertStreak(streak);
  }
}
