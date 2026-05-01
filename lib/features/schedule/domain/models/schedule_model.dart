import 'package:isar/isar.dart';

part 'schedule_model.g.dart';

@Collection()
class ScheduleItem {
  Id id = Isar.autoIncrement;

  late String title;
  late String time;        // display time "06.30"
  late int colorValue;     // Color.value (int)
  late String iconCodePoint;
  late bool isDone;

  late String duration;    // "15 mnt"
  late int durationNum;    // 15

  late String location;
  late String description;
  late String repeat;      // "Harian", "Mingguan", "Tidak Berulang"

  // Start
  late DateTime startDate;
  late int startHour;
  late int startMinute;

  // End
  late DateTime endDate;
  late int endHour;
  late int endMinute;

  late DateTime createdAt;
}