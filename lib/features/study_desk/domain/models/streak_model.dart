import 'package:isar/isar.dart';
 
part 'streak_model.g.dart';
 
@Collection()
class StreakRecord {
  Id id = Isar.autoIncrement;
 
  late DateTime date;          // tanggal streak dicatat
  late int currentStreak;      // streak saat ini (misal 12)
  late int longestStreak;      // rekor terpanjang (misal 28)
  late bool completedToday;
}
 
 