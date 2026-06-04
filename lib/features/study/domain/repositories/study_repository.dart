import '../models/study_session_model.dart';

abstract class StudyRepository {
  Future<List<StudySessionModel>> getSessionsByDate(
    String userId,
    DateTime date,
  );
  Future<List<StudySessionModel>> getSessionsByUser(String userId);
  Future<int> startSession(String userId);
  Future<void> endSession(int sessionId, int durationMinutes);
  Future<int> getTodayStudyMinutes(String userId);
  Future<int> getStudyMinutesByMonth(String userId, int year, int month);
  Future<Map<int, int>> getStudyMinutesByDay(
    String userId,
    int year,
    int month,
  );
  Future<int> getStreak(String userId);
  Future<void> updateStreak(String userId, int streak);
}
