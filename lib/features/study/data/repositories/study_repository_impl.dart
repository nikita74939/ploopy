import '../../domain/models/study_session_model.dart';
import '../../domain/repositories/study_repository.dart';
import '../datasources/study_local_data_source.dart';
import '../datasources/study_remote_data_source.dart';

class StudyRepositoryImpl implements StudyRepository {
  final StudyLocalDataSource localDataSource;
  final StudyRemoteDataSource? remoteDataSource;

  StudyRepositoryImpl({required this.localDataSource, this.remoteDataSource});

  @override
  Future<List<StudySessionModel>> getSessionsByDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final remote = await remoteDataSource?.getSessionsByDate(userId, date);
      if (remote != null) return remote;
    } catch (_) {
      // Backend unavailable: use local study cache.
    }
    return await localDataSource.getSessionsByDate(userId, date);
  }

  @override
  Future<List<StudySessionModel>> getSessionsByUser(String userId) async {
    try {
      final remote = await remoteDataSource?.getSessionsByUser(userId);
      if (remote != null) return remote;
    } catch (_) {
      // Backend unavailable: use local study cache.
    }
    return await localDataSource.getSessionsByUser(userId);
  }

  @override
  Future<int> startSession(String userId) async {
    try {
      final remoteId = await remoteDataSource?.startSession(userId);
      if (remoteId != null) return remoteId;
    } catch (_) {
      // Backend unavailable: create a local-only session.
    }
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
    try {
      await remoteDataSource?.endSession(sessionId, durationMinutes);
    } catch (_) {
      // Backend unavailable: update local cache only.
    }
    await localDataSource.endSession(sessionId, durationMinutes);
  }

  @override
  Future<int> getTodayStudyMinutes(String userId) async {
    try {
      final remote = await remoteDataSource?.getTodayStudyMinutes(userId);
      if (remote != null) return remote;
    } catch (_) {
      // Backend unavailable: use local study cache.
    }
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
    try {
      final remote = await remoteDataSource?.getStudyMinutesByDay(
        userId,
        year,
        month,
      );
      if (remote != null) return remote;
    } catch (_) {
      // Backend unavailable: use local study cache.
    }
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
