import 'package:isar/isar.dart';

part 'achievement_model.g.dart';

@Collection()
class AchievementItem {
  Id id = Isar.autoIncrement;

  late String title;          // "Fire Starter", "Rising Star", dll
  late String desc;           // "Streak 7 hari"
  late String iconCodePoint;  // Icons.local_fire_department.codePoint.toString()
  late int colorValue;        // Color(0xFFFF6B6B).value
  late bool isUnlocked;
  DateTime? unlockedAt;
}