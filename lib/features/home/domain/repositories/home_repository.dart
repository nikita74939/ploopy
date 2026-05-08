import '../../../schedule/data/models/schedule_model.dart';
import '../../../task/data/models/task_model.dart';
abstract class HomeRepository {
  Future<List<ScheduleModel>> getTodaySchedules();
  Future<List<TaskModel>> getTasksOrderedByDeadline();
  Future<ScheduleModel?> getNextSchedule();
  Future<TaskModel?> getNearestTask();
  Future<int> getTodayStudyMinutes();
  Future<List<ScheduleModel>> getSchedulesByDate(DateTime date);
  Future<List<TaskModel>> getTasksByDate(DateTime date);
}