class TaskEntity {
  final int id;
  final String userId;
  final String name;
  final String? subject;
  final DateTime deadline;
  final String? detail;
  final String color;
  final String? icon;
  final bool isPinned;
  final bool isDone;
  final DateTime? completedAt;
  final DateTime createdAt;

  const TaskEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.subject,
    required this.deadline,
    this.detail,
    required this.color,
    this.icon,
    required this.isPinned,
    required this.isDone,
    this.completedAt,
    required this.createdAt,
  });
}
