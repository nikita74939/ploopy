import '../../../schedule/domain/repositories/schedule_repository.dart';
import '../../../study/domain/repositories/study_repository.dart';
import '../../../task/domain/entities/task_entity.dart';
import '../../../task/domain/repositories/task_repository.dart';
import '../../../schedule/domain/entities/schedule_entity.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ScheduleRepository scheduleRepository;
  final TaskRepository taskRepository;
  final StudyRepository studyRepository;

  HomeRepositoryImpl({
    required this.scheduleRepository,
    required this.taskRepository,
    required this.studyRepository,
  });

  @override
  Future<List<ScheduleEntity>> getTodaySchedules(String userId) async {
    return await scheduleRepository.getSchedulesByDate(userId, DateTime.now());
  }

  @override
  Future<List<TaskEntity>> getTasksOrderedByDeadline(String userId) async {
    final tasks = await taskRepository.getAllTasks(userId);
    return tasks..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  @override
  Future<ScheduleEntity?> getNextSchedule(String userId) async {
    final schedules = await scheduleRepository.getUpcomingSchedules(userId);
    if (schedules.isEmpty) return null;
    return schedules.first;
  }

  @override
  Future<TaskEntity?> getNearestTask(String userId) async {
    final tasks = await taskRepository.getAllTasks(userId);
    final incompleteTasks = tasks.where((t) => !t.isCompleted).toList();
    if (incompleteTasks.isEmpty) return null;
    incompleteTasks.sort((a, b) => a.deadline.compareTo(b.deadline));
    return incompleteTasks.first;
  }

  @override
  Future<int> getTodayStudyMinutes(String userId) async {
    return await studyRepository.getTodayStudyMinutes(userId);
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesByDate(
    String userId,
    DateTime date,
  ) async {
    return await scheduleRepository.getSchedulesByDate(userId, date);
  }

  @override
  Future<List<TaskEntity>> getTasksByDate(String userId, DateTime date) async {
    return await taskRepository.getTasksByDate(date, userId);
  }
}
