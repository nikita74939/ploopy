import 'package:isar/isar.dart';
import '../models/schedule_model.dart';

abstract class ScheduleLocalDataSource {
  Future<List<ScheduleModel>> getSchedulesByDate(String userId, DateTime date);
  Future<List<ScheduleModel>> getAllSchedules();
  Future<ScheduleModel?> getScheduleById(int id);
  Future<void> addSchedule(ScheduleModel schedule);
  Future<void> updateSchedule(ScheduleModel schedule);
  Future<void> deleteSchedule(int id);
  Future<List<ScheduleModel>> getUpcomingSchedules(String userId);
  Future<List<ScheduleModel>> getPendingSchedules(String userId);
  Future<void> cacheRemoteSchedules(
    String userId,
    List<ScheduleModel> schedules,
  );
  Future<void> putSchedule(ScheduleModel schedule);
  Future<void> deleteLocalSchedule(int id);
}

class ScheduleLocalDataSourceImpl implements ScheduleLocalDataSource {
  final Isar isar;

  ScheduleLocalDataSourceImpl({required this.isar});

  @override
  Future<List<ScheduleModel>> getSchedulesByDate(
    String userId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final schedules = await isar.scheduleModels
        .filter()
        .userIdEqualTo(userId)
        .startTimeGreaterThan(startOfDay, include: true)
        .startTimeLessThan(endOfDay)
        .findAll();
    return _visibleSorted(schedules);
  }

  @override
  Future<List<ScheduleModel>> getAllSchedules() async {
    final schedules = await isar.scheduleModels.where().findAll();
    return _visibleSorted(schedules);
  }

  @override
  Future<ScheduleModel?> getScheduleById(int id) async {
    final schedule = await isar.scheduleModels.get(id);
    return _isVisible(schedule) ? schedule : null;
  }

  @override
  Future<void> addSchedule(ScheduleModel schedule) async {
    await isar.writeTxn(() async {
      await isar.scheduleModels.put(schedule);
    });
  }

  @override
  Future<void> updateSchedule(ScheduleModel schedule) async {
    await isar.writeTxn(() async {
      await isar.scheduleModels.put(schedule);
    });
  }

  @override
  Future<void> deleteSchedule(int id) async {
    await isar.writeTxn(() async {
      final schedule = await isar.scheduleModels.get(id);
      if (schedule == null) return;

      if (schedule.syncState == 'pendingCreate') {
        await isar.scheduleModels.delete(id);
      } else {
        schedule
          ..remoteId = schedule.remoteId ?? schedule.id
          ..syncState = 'pendingDelete'
          ..deletedAt = DateTime.now();
        await isar.scheduleModels.put(schedule);
      }
    });
  }

  @override
  Future<List<ScheduleModel>> getUpcomingSchedules(String userId) async {
    final now = DateTime.now();
    final schedules = await isar.scheduleModels
        .filter()
        .userIdEqualTo(userId)
        .endTimeGreaterThan(now, include: true)
        .findAll();
    return _visibleSorted(schedules);
  }

  @override
  Future<List<ScheduleModel>> getPendingSchedules(String userId) async {
    final schedules = await isar.scheduleModels
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    return schedules
        .where((schedule) => schedule.syncState.startsWith('pending'))
        .toList();
  }

  @override
  Future<void> cacheRemoteSchedules(
    String userId,
    List<ScheduleModel> schedules,
  ) async {
    await isar.writeTxn(() async {
      final localSchedules = await isar.scheduleModels
          .filter()
          .userIdEqualTo(userId)
          .findAll();
      final dirtyRemoteIds = localSchedules
          .where(
            (schedule) => !_isSynced(schedule) && schedule.remoteId != null,
          )
          .map((schedule) => schedule.remoteId)
          .toSet();
      final dirtyLocalIds = localSchedules
          .where((schedule) => !_isSynced(schedule))
          .map((schedule) => schedule.id)
          .toSet();

      for (final schedule in localSchedules) {
        if (_isSynced(schedule)) {
          await isar.scheduleModels.delete(schedule.id);
        }
      }

      for (final schedule in schedules) {
        final targetId = schedule.remoteId ?? schedule.id;
        if (dirtyRemoteIds.contains(targetId) ||
            dirtyLocalIds.contains(targetId)) {
          continue;
        }
        schedule
          ..id = targetId
          ..remoteId = targetId
          ..syncState = 'synced'
          ..deletedAt = null;
        await isar.scheduleModels.put(schedule);
      }
    });
  }

  @override
  Future<void> putSchedule(ScheduleModel schedule) async {
    await isar.writeTxn(() async {
      await isar.scheduleModels.put(schedule);
    });
  }

  @override
  Future<void> deleteLocalSchedule(int id) async {
    await isar.writeTxn(() async {
      await isar.scheduleModels.delete(id);
    });
  }

  bool _isVisible(ScheduleModel? schedule) {
    return schedule != null &&
        schedule.syncState != 'pendingDelete' &&
        schedule.deletedAt == null;
  }

  bool _isSynced(ScheduleModel schedule) {
    return schedule.syncState.isEmpty || schedule.syncState == 'synced';
  }

  List<ScheduleModel> _visibleSorted(List<ScheduleModel> schedules) {
    final visible = schedules.where(_isVisible).toList();
    visible.sort((a, b) => a.startTime.compareTo(b.startTime));
    return visible;
  }
}
