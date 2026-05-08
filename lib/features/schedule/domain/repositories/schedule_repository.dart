import '../../domain/entities/schedule_entity.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleEntity>> getSchedulesByDate(DateTime date);
  Future<List<ScheduleEntity>> getAllSchedules();
  Future<ScheduleEntity?> getScheduleById(int id);
  Future<void> addSchedule(ScheduleEntity schedule);
  Future<void> updateSchedule(ScheduleEntity schedule);
  Future<void> deleteSchedule(int id);
  Future<List<ScheduleEntity>> getUpcomingSchedules(String userId);
}