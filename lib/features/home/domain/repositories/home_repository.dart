import '../../../schedule/domain/entities/schedule_entity.dart';
import '../../../task/domain/entities/task_entity.dart';

abstract class HomeRepository {
  Future<List<ScheduleEntity>> getTodaySchedules(String userId);
  Future<List<TaskEntity>> getTasksOrderedByDeadline(String userId);
  Future<ScheduleEntity?> getNextSchedule(String userId);
  Future<TaskEntity?> getNearestTask(String userId);
  Future<int> getTodayStudyMinutes(String userId);
  Future<Map<int, int>> getCurrentWeekStudyMinutes(String userId);
  Future<List<ScheduleEntity>> getSchedulesByDate(String userId, DateTime date);
  Future<List<TaskEntity>> getTasksByDate(String userId, DateTime date);
}
