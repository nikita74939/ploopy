import 'package:isar/isar.dart';
import '../models/schedule_model.dart';

abstract class ScheduleLocalDataSource {
  Future<List<ScheduleModel>> getSchedulesByDate(DateTime date);
  Future<List<ScheduleModel>> getAllSchedules();
  Future<ScheduleModel?> getScheduleById(int id);
  Future<void> addSchedule(ScheduleModel schedule);
  Future<void> updateSchedule(ScheduleModel schedule);
  Future<void> deleteSchedule(int id);
  Future<List<ScheduleModel>> getUpcomingSchedules(String userId);
}

class ScheduleLocalDataSourceImpl implements ScheduleLocalDataSource {
  final Isar isar;

  ScheduleLocalDataSourceImpl({required this.isar});

  @override
  Future<List<ScheduleModel>> getSchedulesByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await isar.scheduleModels
        .filter()
        .startTimeGreaterThan(startOfDay)
        .startTimeLessThan(endOfDay)
        .sortByStartTime()
        .findAll();
  }

  @override
  Future<List<ScheduleModel>> getAllSchedules() async {
    return await isar.scheduleModels.where().sortByStartTime().findAll();
  }

  @override
  Future<ScheduleModel?> getScheduleById(int id) async {
    return await isar.scheduleModels.get(id);
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
      await isar.scheduleModels.delete(id);
    });
  }

  @override
  Future<List<ScheduleModel>> getUpcomingSchedules(String userId) async {
    final now = DateTime.now();
    return await isar.scheduleModels
        .filter()
        .userIdEqualTo(userId)
        .startTimeGreaterThan(now)
        .sortByStartTime()
        .findAll();
  }
}
