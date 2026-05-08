import '../../../schedule/domain/repositories/schedule_repository.dart';
import '../../../study/domain/repositories/study_repository.dart';
import '../../../task/data/models/task_model.dart';
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
  Future<List<ScheduleModel>> getTodaySchedules() async {
    final schedules = await scheduleRepository.getSchedulesByDate(
      DateTime.now(),
    );
    return schedules.map((e) => ScheduleModel.fromEntity(e)).toList();
  }

  @override
  Future<List<TaskModel>> getTasksOrderedByDeadline() async {
    final tasks = await taskRepository.getAllTasks('1');
    return tasks..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  @override
  Future<ScheduleModel?> getNextSchedule() async {
    final schedules = await scheduleRepository.getUpcomingSchedules('1');
    if (schedules.isEmpty) return null;
    return ScheduleModel.fromEntity(schedules.first);
  }

  @override
  Future<TaskModel?> getNearestTask() async {
    final tasks = await taskRepository.getAllTasks('1');
    final incompleteTasks = tasks.where((t) => !t.isCompleted).toList();
    if (incompleteTasks.isEmpty) return null;
    incompleteTasks.sort((a, b) => a.deadline.compareTo(b.deadline));
    return incompleteTasks.first;
  }

  @override
  Future<int> getTodayStudyMinutes() async {
    return await studyRepository.getTodayStudyMinutes('1');
  }

  @override
  Future<List<ScheduleModel>> getSchedulesByDate(DateTime date) async {
    final schedules = await scheduleRepository.getSchedulesByDate(date);
    return schedules.map((e) => ScheduleModel.fromEntity(e)).toList();
  }

  @override
  Future<List<TaskModel>> getTasksByDate(DateTime date) async {
    return await taskRepository.getTasksByDate(date, '1');
  }
}
