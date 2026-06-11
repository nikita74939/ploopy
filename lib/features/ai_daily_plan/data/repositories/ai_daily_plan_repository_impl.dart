import '../../../../core/theme/app_colors.dart';
import '../../../schedule/domain/entities/schedule_entity.dart';
import '../../../schedule/domain/repositories/schedule_repository.dart';
import '../../../task/domain/entities/task_entity.dart';
import '../../../task/domain/repositories/task_repository.dart';
import '../../domain/repositories/ai_daily_plan_repository.dart';
import '../datasources/groq_ai_service.dart';
import '../models/ai_daily_plan_model.dart';

class AiDailyPlanRepositoryImpl implements AiDailyPlanRepository {
  final TaskRepository taskRepository;
  final ScheduleRepository scheduleRepository;
  final GroqAiService aiService;

  AiDailyPlanRepositoryImpl({
    required this.taskRepository,
    required this.scheduleRepository,
    required this.aiService,
  });

  @override
  Future<AiDailyPlanResponseModel> generatePlan({
    required String userId,
    required DateTime date,
  }) async {
    final context = await _loadContext(userId: userId, date: date);
    final response = await aiService.generateDailyPlan(
      AiDailyPlanRequestModel(
        userId: userId,
        date: date,
        tasks: context.tasks,
        schedules: context.schedules,
      ),
    );
    _validatePlan(response, context.schedules, date);
    return response;
  }

  @override
  Future<AiDailyPlanResponseModel> revisePlan({
    required String userId,
    required DateTime date,
    required AiDailyPlanResponseModel previousPlan,
    required String instruction,
  }) async {
    if (instruction.trim().isEmpty) {
      throw Exception('Instruksi revisi tidak boleh kosong.');
    }
    final context = await _loadContext(userId: userId, date: date);
    final response = await aiService.generateDailyPlan(
      AiDailyPlanRequestModel(
        userId: userId,
        date: date,
        tasks: context.tasks,
        schedules: context.schedules,
        previousPlan: previousPlan,
        revisionInstruction: instruction,
      ),
    );
    _validatePlan(response, context.schedules, date);
    return response;
  }

  @override
  Future<void> acceptPlan({
    required String userId,
    required AiDailyPlanResponseModel plan,
  }) async {
    if (plan.plans.isEmpty) {
      throw Exception('Tidak ada jadwal AI yang bisa disimpan.');
    }

    for (final item in plan.plans) {
      await scheduleRepository.addSchedule(
        ScheduleEntity(
          id: 0,
          userId: userId,
          name: item.title,
          startTime: item.startTime,
          endTime: item.endTime,
          recurrence: 'None',
          location: item.type == 'break' ? 'Istirahat' : null,
          color: AppColors.primary.toARGB32(),
          description: _aiDescription(item),
          url: 'ploopy://ai-daily-plan',
          icon: 'auto_awesome',
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<_DailyPlanContext> _loadContext({
    required String userId,
    required DateTime date,
  }) async {
    final results = await Future.wait<Object>([
      taskRepository.getTasksByUser(userId),
      scheduleRepository.getSchedulesByDate(userId, date),
    ]);

    final tasks =
        (results[0] as List<TaskEntity>)
            .where((task) => !task.isCompleted)
            .toList()
          ..sort((a, b) {
            if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
            return a.deadline.compareTo(b.deadline);
          });

    final schedules = results[1] as List<ScheduleEntity>;
    return _DailyPlanContext(tasks: tasks, schedules: schedules);
  }

  void _validatePlan(
    AiDailyPlanResponseModel response,
    List<ScheduleEntity> existingSchedules,
    DateTime date,
  ) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final sortedPlans = [...response.plans]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    for (final plan in sortedPlans) {
      if (plan.source != 'ai') {
        throw Exception('Response AI harus memiliki source "ai".');
      }
      if (plan.startTime.isBefore(dayStart) || !plan.endTime.isBefore(dayEnd)) {
        throw Exception('AI membuat jadwal di luar tanggal yang dipilih.');
      }
      for (final schedule in existingSchedules) {
        if (_overlaps(
          plan.startTime,
          plan.endTime,
          schedule.startTime,
          schedule.endTime,
        )) {
          throw Exception(
            'AI membuat jadwal yang bentrok dengan "${schedule.name}".',
          );
        }
      }
    }

    for (var i = 1; i < sortedPlans.length; i++) {
      final previous = sortedPlans[i - 1];
      final current = sortedPlans[i];
      if (_overlaps(
        previous.startTime,
        previous.endTime,
        current.startTime,
        current.endTime,
      )) {
        throw Exception('AI membuat jadwal yang saling bertabrakan.');
      }
    }
  }

  bool _overlaps(
    DateTime startA,
    DateTime endA,
    DateTime startB,
    DateTime endB,
  ) {
    return startA.isBefore(endB) && endA.isAfter(startB);
  }

  String _aiDescription(AiDailyPlanItemModel item) {
    final buffer = StringBuffer('Dibuat oleh AI Daily Plan.');
    if (item.description != null && item.description!.trim().isNotEmpty) {
      buffer.write('\n${item.description!.trim()}');
    }
    return buffer.toString();
  }
}

class _DailyPlanContext {
  final List<TaskEntity> tasks;
  final List<ScheduleEntity> schedules;

  const _DailyPlanContext({required this.tasks, required this.schedules});
}
