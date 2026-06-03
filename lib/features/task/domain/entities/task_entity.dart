class TaskEntity {
  final int id;
  final String userId;
  final String name;
  final String? subject;
  final DateTime deadline;
  final String? details;
  final int color;
  final String? iconName;
  final bool isPinned;
  final bool isCompleted;
  final DateTime createdAt;

  const TaskEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.subject,
    required this.deadline,
    this.details,
    required this.color,
    this.iconName,
    required this.isPinned,
    required this.isCompleted,
    required this.createdAt,
  });

  TaskEntity copyWith({
    int? id,
    String? userId,
    String? name,
    String? subject,
    DateTime? deadline,
    String? details,
    int? color,
    String? iconName,
    bool? isPinned,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      deadline: deadline ?? this.deadline,
      details: details ?? this.details,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
      isPinned: isPinned ?? this.isPinned,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
