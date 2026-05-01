import 'package:isar/isar.dart';
 
part 'study_session_model.g.dart';
 
@Collection()
class StudySession {
  Id id = Isar.autoIncrement;
 
  late DateTime date;
  late int durationMinutes;
  late String subject;      // "Matematika", "Bahasa Inggris", dll
  late String activityType; // "belajar", "meditasi", "olahraga"
  late DateTime createdAt;
}
 