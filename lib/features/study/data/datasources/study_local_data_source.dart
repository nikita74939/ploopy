import 'package:isar/isar.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/models/study_session_model.dart';

abstract class StudyLocalDataSource {
  Future<List<StudySessionModel>> getSessionsByDate(DateTime date);
  Future<List<StudySessionModel>> getSessionsByUser(String userId);
  Future<void> startSession(StudySessionModel session);
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

class StudyLocalDataSourceImpl implements StudyLocalDataSource {
  final Isar isar;

  StudyLocalDataSourceImpl({required this.isar});

  @override
  Future<List<StudySessionModel>> getSessionsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await isar.studySessionModels
        .filter()
        .startTimeGreaterThan(startOfDay)
        .startTimeLessThan(endOfDay)
        .findAll();
  }

  @override
  Future<List<StudySessionModel>> getSessionsByUser(String userId) async {
    return await isar.studySessionModels
        .filter()
        .userIdEqualTo(userId)
        .sortByStartTimeDesc()
        .findAll();
  }

  @override
  Future<void> startSession(StudySessionModel session) async {
    await isar.writeTxn(() async {
      await isar.studySessionModels.put(session);
    });
  }

  @override
  Future<void> endSession(int sessionId, int durationMinutes) async {
    final session = await isar.studySessionModels.get(sessionId);
    if (session != null) {
      session.endTime = DateTime.now();
      session.durationMinutes = durationMinutes;
      await isar.writeTxn(() async {
        await isar.studySessionModels.put(session);
      });
    }
  }

  @override
  Future<int> getTodayStudyMinutes(String userId) async {
    final today = DateTime.now();
    final sessions = await getSessionsByDate(today);

    final totalMinutes = sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationMinutes,
    );

    return totalMinutes;
  }

  @override
  Future<int> getStudyMinutesByMonth(String userId, int year, int month) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(
      year,
      month + 1,
      1,
    ).subtract(const Duration(microseconds: 1));

    final sessions = await isar.studySessionModels
        .filter()
        .userIdEqualTo(userId)
        .startTimeGreaterThan(startOfMonth, include: true)
        .startTimeLessThan(endOfMonth, include: true)
        .findAll();

    return sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationMinutes,
    );
  }

  @override
  Future<Map<int, int>> getStudyMinutesByDay(
    String userId,
    int year,
    int month,
  ) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    final sessions = await isar.studySessionModels
        .filter()
        .userIdEqualTo(userId)
        .startTimeGreaterThan(startOfMonth)
        .startTimeLessThan(endOfMonth)
        .findAll();

    final Map<int, int> result = {};
    for (final session in sessions) {
      final day = session.startTime.day;
      result[day] = (result[day] ?? 0) + session.durationMinutes;
    }
    return result;
  }

  @override
  Future<int> getStreak(String userId) async {
    final user = await isar.userModels.getByUserId(userId);
    return user?.streak ?? 0;
  }

  @override
  Future<void> updateStreak(String userId, int streak) async {
    final user = await isar.userModels.getByUserId(userId);
    if (user != null) {
      user.streak = streak;
      if (streak > user.longestStreak) {
        user.longestStreak = streak;
      }
      await isar.writeTxn(() async {
        await isar.userModels.put(user);
      });
    }
  }
}
