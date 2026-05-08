import '../../../auth/data/models/user_model.dart';
import '../../data/models/achievement_model.dart';
import '../../data/models/achievement_supabase_model.dart';
import '../../data/models/app_settings_model.dart';
import '../../data/models/friendship_model.dart';

abstract class ProfileRepository {
  // User
  Future<UserModel?> getUserById(String userId);
  Future<void> updateUser(UserModel user);

  // Achievements - menggunakan Supabase model
  Future<List<AchievementSupabaseModel>> getAllAchievements();
  Future<List<UserAchievementSupabaseModel>> getUserAchievements(String userId);
  Future<void> unlockAchievement(String userId, String achievementId);

  // Friends - menggunakan tabel friendships
  Future<List<FriendshipModel>> getFriends(String userId);
  Future<FriendshipModel> sendFriendRequest(String requesterId, String addresseeId);
  Future<void> acceptFriendRequest(String friendshipId);
  Future<void> removeFriend(String friendshipId);

  // Settings
  Future<AppSettingsModel> getAppSettings(String userId);
  Future<void> upsertAppSettings(AppSettingsModel settings);

  // Streaks
  Future<StreakModel> getStreak(String userId);
  Future<void> upsertStreak(StreakModel streak);
}