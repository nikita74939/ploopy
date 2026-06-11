import 'package:isar/isar.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/achievement_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserModel?> getUserById(String userId);
  Future<void> updateUser(UserModel user);
  Future<List<AchievementModel>> getAllAchievements();
  Future<List<UserAchievementModel>> getUserAchievements(String userId);
  Future<void> saveAchievement(AchievementModel achievement);
  Future<void> saveUserAchievement(UserAchievementModel userAchievement);
  Future<void> clearAchievements();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final Isar isar;

  ProfileLocalDataSourceImpl({required this.isar});

  @override
  Future<UserModel?> getUserById(String userId) async {
    // Gunakan index userId (String) bukan Isar Id (int)
    return await isar.userModels
        .filter()
        .userIdEqualTo(userId)
        .findFirst();
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await isar.writeTxn(() async {
      await isar.userModels.put(user);
    });
  }

  @override
  Future<List<AchievementModel>> getAllAchievements() async {
    return await isar.achievementModels.where().findAll();
  }

  @override
  Future<List<UserAchievementModel>> getUserAchievements(String userId) async {
    return await isar.userAchievementModels
        .filter()
        .userIdEqualTo(userId)
        .findAll();
  }

  @override
  Future<void> saveAchievement(AchievementModel achievement) async {
    await isar.writeTxn(() async {
      await isar.achievementModels.put(achievement);
    });
  }

  @override
  Future<void> saveUserAchievement(UserAchievementModel userAchievement) async {
    await isar.writeTxn(() async {
      await isar.userAchievementModels.put(userAchievement);
    });
  }

  @override
  Future<void> clearAchievements() async {
    await isar.writeTxn(() async {
      await isar.achievementModels.clear();
    });
  }
}