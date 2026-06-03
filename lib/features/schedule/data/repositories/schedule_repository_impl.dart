import '../../domain/entities/schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_local_data_source.dart';
import '../datasources/schedule_remote_data_source.dart';
import '../models/schedule_model.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleLocalDataSource localDataSource;
  final ScheduleRemoteDataSource remoteDataSource;

  ScheduleRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<ScheduleEntity>> getSchedulesByDate(DateTime date) async {
    final models = await _getFreshOrCachedSchedulesByDate(date);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ScheduleEntity>> getAllSchedules() async {
    final models = await _getFreshOrCachedSchedules();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ScheduleEntity?> getScheduleById(int id) async {
    final model = await localDataSource.getScheduleById(id);
    return model?.toEntity();
  }

  @override
  Future<void> addSchedule(ScheduleEntity schedule) async {
    final model = ScheduleModel.fromEntity(schedule)
      ..syncState = 'pendingCreate';
    await localDataSource.addSchedule(model);
    await _syncPending(schedule.userId);
  }

  @override
  Future<void> updateSchedule(ScheduleEntity schedule) async {
    final existing = await localDataSource.getScheduleById(schedule.id);
    final model = ScheduleModel.fromEntity(schedule)
      ..remoteId = existing?.remoteId ?? (schedule.id > 0 ? schedule.id : null)
      ..syncState = existing?.syncState == 'pendingCreate'
          ? 'pendingCreate'
          : 'pendingUpdate';
    await localDataSource.updateSchedule(model);
    await _syncPending(schedule.userId);
  }

  @override
  Future<void> deleteSchedule(int id) async {
    final schedule = await localDataSource.getScheduleById(id);
    await localDataSource.deleteSchedule(id);
    if (schedule != null) {
      await _syncPending(schedule.userId);
    }
  }

  @override
  Future<List<ScheduleEntity>> getUpcomingSchedules(String userId) async {
    await _syncPending(userId);
    try {
      final remoteSchedules = await remoteDataSource.getAllSchedules();
      await localDataSource.cacheRemoteSchedules(userId, remoteSchedules);
    } catch (_) {
      // Offline: use cached schedules.
    }
    final models = await localDataSource.getUpcomingSchedules(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  Future<List<ScheduleModel>> _getFreshOrCachedSchedules() async {
    final cached = await localDataSource.getAllSchedules();
    final userId = cached.isNotEmpty ? cached.first.userId : null;
    if (userId != null) await _syncPending(userId);

    try {
      final remoteSchedules = await remoteDataSource.getAllSchedules();
      final effectiveUserId =
          userId ??
          (remoteSchedules.isNotEmpty ? remoteSchedules.first.userId : null);
      if (effectiveUserId != null) {
        await localDataSource.cacheRemoteSchedules(
          effectiveUserId,
          remoteSchedules,
        );
      }
    } catch (_) {
      // Offline or backend unavailable.
    }
    return localDataSource.getAllSchedules();
  }

  Future<List<ScheduleModel>> _getFreshOrCachedSchedulesByDate(
    DateTime date,
  ) async {
    final cached = await localDataSource.getAllSchedules();
    final userId = cached.isNotEmpty ? cached.first.userId : null;
    if (userId != null) await _syncPending(userId);

    try {
      final remoteSchedules = await remoteDataSource.getAllSchedules();
      final effectiveUserId =
          userId ??
          (remoteSchedules.isNotEmpty ? remoteSchedules.first.userId : null);
      if (effectiveUserId != null) {
        await localDataSource.cacheRemoteSchedules(
          effectiveUserId,
          remoteSchedules,
        );
      }
    } catch (_) {
      // Offline or backend unavailable.
    }
    return localDataSource.getSchedulesByDate(date);
  }

  Future<void> _syncPending(String userId) async {
    final pendingSchedules = await localDataSource.getPendingSchedules(userId);
    for (final schedule in pendingSchedules) {
      try {
        if (schedule.syncState == 'pendingCreate') {
          final synced = await remoteDataSource.addSchedule(schedule);
          if (schedule.id != synced.id) {
            await localDataSource.deleteLocalSchedule(schedule.id);
          }
          await localDataSource.putSchedule(synced);
        } else if (schedule.syncState == 'pendingUpdate') {
          final remoteId = schedule.remoteId ?? schedule.id;
          final synced = await remoteDataSource.updateSchedule(
            schedule..remoteId = remoteId,
          );
          if (schedule.id != synced.id) {
            await localDataSource.deleteLocalSchedule(schedule.id);
          }
          await localDataSource.putSchedule(synced);
        } else if (schedule.syncState == 'pendingDelete') {
          final remoteId = schedule.remoteId ?? schedule.id;
          await remoteDataSource.deleteSchedule(remoteId);
          await localDataSource.deleteLocalSchedule(schedule.id);
        }
      } catch (_) {
        return;
      }
    }
  }
}
