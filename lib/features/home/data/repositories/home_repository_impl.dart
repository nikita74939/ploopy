import '../../../schedule/domain/repositories/schedule_repository.dart';
import '../../../study/domain/repositories/study_repository.dart';
import '../../../task/data/models/task_model.dart';
import '../../../task/domain/entities/task_entity.dart';
import '../../../task/domain/repositories/task_repository.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../schedule/data/models/schedule_model.dart';

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
  Future<List<ScheduleModel>> getTodaySchedules(String userId) async {
    final schedules = await scheduleRepository.getSchedulesByDate(
      userId,
      DateTime.now(),
    );
    return schedules.map((e) => ScheduleModel.fromEntity(e)).toList();
  }

  @override
  Future<List<TaskModel>> getTasksOrderedByDeadline(String userId) async {
    final tasks = await taskRepository.getAllTasks(userId);
    final models = tasks.map(_taskModelFromEntity).toList();
    return models..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  @override
  Future<ScheduleModel?> getNextSchedule(String userId) async {
    final schedules = await scheduleRepository.getUpcomingSchedules(userId);
    if (schedules.isEmpty) return null;
    return ScheduleModel.fromEntity(schedules.first);
  }

  @override
  Future<TaskModel?> getNearestTask(String userId) async {
    final tasks = await taskRepository.getAllTasks(userId);
    final incompleteTasks = tasks.where((t) => !t.isCompleted).toList();
    if (incompleteTasks.isEmpty) return null;
    incompleteTasks.sort((a, b) => a.deadline.compareTo(b.deadline));
    return _taskModelFromEntity(incompleteTasks.first);
  }

  @override
  Future<int> getTodayStudyMinutes(String userId) async {
    return await studyRepository.getTodayStudyMinutes(userId);
  }

  @override
  Future<List<ScheduleModel>> getSchedulesByDate(
    String userId,
    DateTime date,
  ) async {
    final schedules = await scheduleRepository.getSchedulesByDate(userId, date);
    return schedules.map((e) => ScheduleModel.fromEntity(e)).toList();
  }

  @override
  Future<List<TaskModel>> getTasksByDate(String userId, DateTime date) async {
    final tasks = await taskRepository.getTasksByDate(date, userId);
    return tasks.map(_taskModelFromEntity).toList();
  }

  TaskModel _taskModelFromEntity(TaskEntity entity) {
    return TaskModel()
      ..id = entity.id
      ..userId = entity.userId
      ..name = entity.name
      ..subject = entity.subject
      ..deadline = entity.deadline
      ..details = entity.details
      ..color = entity.color
      ..iconName = entity.iconName
      ..isPinned = entity.isPinned
      ..isCompleted = entity.isCompleted
      ..createdAt = entity.createdAt;
  }
}
