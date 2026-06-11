import '../../../auth/domain/entities/user_entity.dart';
import '../entities/achievement_entity.dart';
import '../entities/app_settings_entity.dart';
import '../entities/friendship_entity.dart';
import '../entities/streak_entity.dart';

abstract class ProfileRepository {
  // User
  Future<UserEntity?> getUserById(String userId);
  Future<void> updateUser(UserEntity user);

  // Achievements
  Future<List<AchievementEntity>> getAllAchievements();
  Future<List<UserAchievementEntity>> getUserAchievements(String userId);
  Future<void> unlockAchievement(String userId, String achievementId);

  // Friends
  Future<List<ProfileFriendshipEntity>> getFriends(String userId);
  Future<ProfileFriendshipEntity> sendFriendRequest(
    String requesterId,
    String addresseeId,
  );
  Future<void> acceptFriendRequest(String friendshipId);
  Future<void> removeFriend(String friendshipId);

  // Settings
  Future<ProfileAppSettingsEntity> getAppSettings(String userId);
  Future<void> upsertAppSettings(ProfileAppSettingsEntity settings);

  // Streaks
  Future<ProfileStreakEntity> getStreak(String userId);
  Future<void> upsertStreak(ProfileStreakEntity streak);
}
