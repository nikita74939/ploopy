import '../../../schedule/data/models/schedule_model.dart';
import '../../../task/data/models/task_model.dart';

abstract class HomeRepository {
  Future<List<ScheduleModel>> getTodaySchedules(String userId);
  Future<List<TaskModel>> getTasksOrderedByDeadline(String userId);
  Future<ScheduleModel?> getNextSchedule(String userId);
  Future<TaskModel?> getNearestTask(String userId);
  Future<int> getTodayStudyMinutes(String userId);
  Future<List<ScheduleModel>> getSchedulesByDate(String userId, DateTime date);
  Future<List<TaskModel>> getTasksByDate(String userId, DateTime date);
}
