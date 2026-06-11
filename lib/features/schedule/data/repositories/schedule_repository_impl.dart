import '../../../../core/services/notification_service.dart';
import '../../../notification/data/datasources/notification_local_data_source.dart';
import '../../../notification/data/models/notification_model.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_local_data_source.dart';
import '../datasources/schedule_remote_data_source.dart';
import '../models/schedule_model.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleLocalDataSource localDataSource;
  final ScheduleRemoteDataSource remoteDataSource;
  final NotificationLocalDataSource? notificationLocalDataSource;

  ScheduleRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    this.notificationLocalDataSource,
  });

  @override
  Future<List<ScheduleEntity>> getSchedulesByDate(
    String userId,
    DateTime date,
  ) async {
    final models = await _getFreshOrCachedSchedulesByDate(userId, date);
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
    await _upsertScheduleNotification(model);
    await _syncPending(schedule.userId);
  }

  @override
  Future<void> updateSchedule(ScheduleEntity schedule) async {
    final existing = await localDataSource.getScheduleById(schedule.id);
    if (existing != null) await _cancelScheduleNotification(existing);
    final model = ScheduleModel.fromEntity(schedule)
      ..remoteId = existing?.remoteId ?? (schedule.id > 0 ? schedule.id : null)
      ..syncState = existing?.syncState == 'pendingCreate'
          ? 'pendingCreate'
          : 'pendingUpdate';
    await localDataSource.updateSchedule(model);
    await _upsertScheduleNotification(model);
    await _syncPending(schedule.userId);
  }

  @override
  Future<void> deleteSchedule(int id) async {
    final schedule = await localDataSource.getScheduleById(id);
    if (schedule != null) await _cancelScheduleNotification(schedule);
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
    await _syncScheduleNotifications(models);
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
    final models = await localDataSource.getAllSchedules();
    await _syncScheduleNotifications(models);
    return models;
  }

  Future<List<ScheduleModel>> _getFreshOrCachedSchedulesByDate(
    String userId,
    DateTime date,
  ) async {
    await _syncPending(userId);

    try {
      final remoteSchedules = await remoteDataSource.getAllSchedules();
      await localDataSource.cacheRemoteSchedules(userId, remoteSchedules);
    } catch (_) {
      // Offline or backend unavailable.
    }
    final models = await localDataSource.getSchedulesByDate(userId, date);
    await _syncScheduleNotifications(models);
    return models;
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

  Future<void> _upsertScheduleNotification(ScheduleModel schedule) async {
    final fireTime = _nextFireTime(schedule);
    final notificationId = _notificationIdFor(schedule);

    await NotificationService.cancelNotification(notificationId);
    if (fireTime == null) {
      await notificationLocalDataSource?.deleteNotification(notificationId);
      return;
    }

    final title = 'Jadwal dimulai';
    final body = _notificationBody(schedule, fireTime);
    await notificationLocalDataSource?.addNotification(
      NotificationModel()
        ..id = notificationId
        ..title = title
        ..description = body
        ..tag = 'schedule'
        ..iconName = 'schedule'
        ..relatedId = schedule.remoteId?.toString() ?? schedule.id.toString()
        ..isRead = false
        ..createdAt = fireTime
        ..userId = schedule.userId,
    );

    await NotificationService.scheduleNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledTime: fireTime,
      payload: 'schedule:${schedule.id}',
    );
  }

  Future<void> _syncScheduleNotifications(List<ScheduleModel> schedules) async {
    for (final schedule in schedules) {
      await _upsertScheduleNotification(schedule);
    }
  }

  Future<void> _cancelScheduleNotification(ScheduleModel schedule) async {
    final notificationId = _notificationIdFor(schedule);
    await NotificationService.cancelNotification(notificationId);
    await notificationLocalDataSource?.deleteNotification(notificationId);
  }

  DateTime? _nextFireTime(ScheduleModel schedule) {
    final now = DateTime.now();
    var next = schedule.startTime;
    final repeatUntil = schedule.repeatUntil;

    switch (schedule.repeatType) {
      case RepeatType.none:
        break;
      case RepeatType.daily:
        while (!next.isAfter(now)) {
          next = next.add(const Duration(days: 1));
        }
        break;
      case RepeatType.weekly:
        while (!next.isAfter(now)) {
          next = next.add(const Duration(days: 7));
        }
        break;
      case RepeatType.monthly:
        while (!next.isAfter(now)) {
          next = DateTime(
            next.year,
            next.month + 1,
            next.day,
            next.hour,
            next.minute,
            next.second,
          );
        }
        break;
    }

    if (!next.isAfter(now)) return null;
    if (repeatUntil != null && next.isAfter(repeatUntil)) return null;
    return next;
  }

  String _notificationBody(ScheduleModel schedule, DateTime fireTime) {
    final hour = fireTime.hour.toString().padLeft(2, '0');
    final minute = fireTime.minute.toString().padLeft(2, '0');
    final location = schedule.location?.trim();
    final place = location == null || location.isEmpty ? '' : ' di $location';
    return '${schedule.name} mulai pukul $hour:$minute$place.';
  }

  int _notificationIdFor(ScheduleModel schedule) {
    return _stablePositiveHash(
      [
        'schedule',
        schedule.userId,
        schedule.name.trim().toLowerCase(),
        schedule.startTime.toUtc().toIso8601String(),
        schedule.location?.trim().toLowerCase() ?? '',
      ].join('|'),
    );
  }

  int _stablePositiveHash(String value) {
    var hash = 0x811c9dc5;
    for (final code in value.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }
}
