import '../../domain/models/study_session_model.dart';
import '../../domain/repositories/study_repository.dart';
import '../datasources/study_local_data_source.dart';

class StudyRepositoryImpl implements StudyRepository {
  final StudyLocalDataSource localDataSource;

  StudyRepositoryImpl({required this.localDataSource});

  @override
  Future<List<StudySessionModel>> getSessionsByDate(DateTime date) async {
    return await localDataSource.getSessionsByDate(date);
  }

  @override
  Future<List<StudySessionModel>> getSessionsByUser(String userId) async {
    return await localDataSource.getSessionsByUser(userId);
  }

  @override
  Future<int> startSession(String userId) async {
    final session = StudySessionModel.create(
      startTime: DateTime.now(),
      durationMinutes: 0,
      userId: userId,
    );
    await localDataSource.startSession(session);
    return session.id;
  }

  @override
  Future<void> endSession(int sessionId, int durationMinutes) async {
    await localDataSource.endSession(sessionId, durationMinutes);
  }

  @override
  Future<int> getTodayStudyMinutes(String userId) async {
    return await localDataSource.getTodayStudyMinutes(userId);
  }

  @override
  Future<int> getStudyMinutesByMonth(String userId, int year, int month) async {
    return await localDataSource.getStudyMinutesByMonth(userId, year, month);
  }

  @override
  Future<Map<int, int>> getStudyMinutesByDay(
    String userId,
    int year,
    int month,
  ) async {
    return await localDataSource.getStudyMinutesByDay(userId, year, month);
  }

  @override
  Future<int> getStreak(String userId) async {
    return await localDataSource.getStreak(userId);
  }

  @override
  Future<void> updateStreak(String userId, int streak) async {
    await localDataSource.updateStreak(userId, streak);
  }
}
