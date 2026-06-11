import 'package:isar/isar.dart';

part 'achievement_model.g.dart';

@collection
class AchievementModel {
  Id id = Isar.autoIncrement;

  late String name;
  late String description;
  late String iconName;
  late String type; // study_time, streak, task_done
  late int requirement;
  late int rewardPoints;
  bool isUnlocked = false;
  DateTime? unlockedAt;

  AchievementModel();

  factory AchievementModel.create({
    required String name,
    required String description,
    required String iconName,
    required String type,
    required int requirement,
    required int rewardPoints,
  }) {
    return AchievementModel()
      ..name = name
      ..description = description
      ..iconName = iconName
      ..type = type
      ..requirement = requirement
      ..rewardPoints = rewardPoints
      ..isUnlocked = false;
  }
}

@collection
class UserAchievementModel {
  Id id = Isar.autoIncrement;

  late String userId;
  late int achievementId;
  late DateTime unlockedAt;

  UserAchievementModel();

  factory UserAchievementModel.create({
    required String userId,
    required int achievementId,
  }) {
    return UserAchievementModel()
      ..userId = userId
      ..achievementId = achievementId
      ..unlockedAt = DateTime.now();
  }
}
