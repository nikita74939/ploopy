import 'package:isar/isar.dart';

part 'study_session_model.g.dart';

@collection
class StudySessionModel {
  Id id = Isar.autoIncrement;

  late DateTime startTime;
  DateTime? endTime;
  late int durationMinutes;
  late String userId;

  StudySessionModel();

  factory StudySessionModel.create({
    required DateTime startTime,
    DateTime? endTime,
    required int durationMinutes,
    required String userId,
  }) {
    return StudySessionModel()
      ..startTime = startTime
      ..endTime = endTime
      ..durationMinutes = durationMinutes
      ..userId = userId;
  }
}
