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
  Future<List<TaskEntity>>? _inFlightTasks;
  String? _inFlightTasksUserId;

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
    final tasks = await _getDashboardTasks(userId);
    final urgentTasks = tasks.where((task) => !task.isCompleted).toList();
    return urgentTasks..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  @override
  Future<ScheduleEntity?> getNextSchedule(String userId) async {
    final schedules = await scheduleRepository.getUpcomingSchedules(userId);
    if (schedules.isEmpty) return null;
    return schedules.first;
  }

  @override
  Future<TaskEntity?> getNearestTask(String userId) async {
    final tasks = await _getDashboardTasks(userId);
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
  Future<Map<int, int>> getCurrentWeekStudyMinutes(String userId) async {
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final weekDates = List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      return DateTime(date.year, date.month, date.day);
    });

    final months = {
      for (final date in weekDates) DateTime(date.year, date.month),
    };
    final minutesByMonth = <DateTime, Map<int, int>>{};
    for (final month in months) {
      minutesByMonth[month] = await studyRepository.getStudyMinutesByDay(
        userId,
        month.year,
        month.month,
      );
    }

    return {
      for (final date in weekDates)
        date.day:
            minutesByMonth[DateTime(date.year, date.month)]?[date.day] ?? 0,
    };
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

  @override
  Future<void> toggleTaskCompletion(int taskId, String userId) async {
    await taskRepository.toggleTaskCompletion(taskId, userId);
  }

  Future<List<TaskEntity>> _getDashboardTasks(String userId) {
    if (_inFlightTasks != null && _inFlightTasksUserId == userId) {
      return _inFlightTasks!;
    }

    final future = taskRepository.getAllTasks(userId);
    _inFlightTasks = future;
    _inFlightTasksUserId = userId;
    return future.whenComplete(() {
      if (identical(_inFlightTasks, future)) {
        _inFlightTasks = null;
        _inFlightTasksUserId = null;
      }
    });
  }
}
