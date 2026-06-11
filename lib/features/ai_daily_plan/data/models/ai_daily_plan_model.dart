import '../../../schedule/domain/entities/schedule_entity.dart';
import '../../../task/domain/entities/task_entity.dart';

class AiDailyPlanRequestModel {
  final String userId;
  final DateTime date;
  final List<TaskEntity> tasks;
  final List<ScheduleEntity> schedules;
  final AiDailyPlanResponseModel? previousPlan;
  final String? revisionInstruction;

  const AiDailyPlanRequestModel({
    required this.userId,
    required this.date,
    required this.tasks,
    required this.schedules,
    this.previousPlan,
    this.revisionInstruction,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'tasks': tasks.map(_taskToJson).toList(),
      'existing_schedules': schedules.map(_scheduleToJson).toList(),
      if (previousPlan != null) 'previous_plan': previousPlan!.toJson(),
      if (revisionInstruction != null && revisionInstruction!.trim().isNotEmpty)
        'revision_instruction': revisionInstruction!.trim(),
    };
  }

  Map<String, dynamic> _taskToJson(TaskEntity task) {
    return {
      'id': task.id.toString(),
      'title': task.name,
      'subject': task.subject,
      'details': task.details,
      'deadline': task.deadline.toIso8601String(),
      'priority': task.isPinned ? 'high' : 'normal',
      'is_completed': task.isCompleted,
      'estimated_duration_minutes': null,
    };
  }

  Map<String, dynamic> _scheduleToJson(ScheduleEntity schedule) {
    return {
      'id': schedule.id.toString(),
      'title': schedule.name,
      'description': schedule.description,
      'start_time': schedule.startTime.toIso8601String(),
      'end_time': schedule.endTime.toIso8601String(),
      'location': schedule.location,
    };
  }
}

class AiDailyPlanResponseModel {
  final String summary;
  final List<AiDailyPlanItemModel> plans;

  const AiDailyPlanResponseModel({required this.summary, required this.plans});

  factory AiDailyPlanResponseModel.fromJson(Map<String, dynamic> json) {
    final rows = json['plans'];
    if (rows is! List) {
      throw const FormatException('Response AI tidak memiliki daftar jadwal.');
    }

    return AiDailyPlanResponseModel(
      summary: json['summary']?.toString().trim().isNotEmpty == true
          ? json['summary'].toString().trim()
          : 'Rencana harian berhasil dibuat.',
      plans: rows
          .map(
            (row) => AiDailyPlanItemModel.fromJson(row as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'plans': plans.map((plan) => plan.toJson()).toList(),
    };
  }
}

class AiDailyPlanItemModel {
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String type;
  final String source;
  final String? relatedTaskId;

  const AiDailyPlanItemModel({
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.source,
    this.relatedTaskId,
  });

  factory AiDailyPlanItemModel.fromJson(Map<String, dynamic> json) {
    final title = json['title']?.toString().trim();
    final startRaw = json['start_time']?.toString();
    final endRaw = json['end_time']?.toString();
    if (title == null || title.isEmpty || startRaw == null || endRaw == null) {
      throw const FormatException('Item jadwal AI tidak lengkap.');
    }

    final startTime = DateTime.parse(startRaw).toLocal();
    final endTime = DateTime.parse(endRaw).toLocal();
    if (!endTime.isAfter(startTime)) {
      throw const FormatException('Waktu selesai harus setelah waktu mulai.');
    }

    return AiDailyPlanItemModel(
      title: title,
      description: json['description']?.toString().trim(),
      startTime: startTime,
      endTime: endTime,
      type: json['type']?.toString().trim().isNotEmpty == true
          ? json['type'].toString().trim()
          : 'task',
      source: json['source']?.toString().trim().isNotEmpty == true
          ? json['source'].toString().trim()
          : 'ai',
      relatedTaskId: json['related_task_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'type': type,
      'source': source,
      'related_task_id': relatedTaskId,
    };
  }
}
