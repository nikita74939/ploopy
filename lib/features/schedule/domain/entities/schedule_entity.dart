class ScheduleEntity {
  final int id;
  final String userId;
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final String recurrence; // none | daily | weekly | monthly
  final DateTime? recurrenceEnd;
  final int color; // stored as int (ARGB), same as ScheduleModel
  final String? description;
  final String? url; // maps to ScheduleModel.link
  final String icon; // maps to ScheduleModel.iconName
  final DateTime createdAt;

  const ScheduleEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.recurrence = 'None',
    this.recurrenceEnd,
    required this.color,
    this.description,
    this.url,
    this.icon = 'event',
    required this.createdAt,
  });

  ScheduleEntity copyWith({
    int? id,
    String? userId,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    String? recurrence,
    DateTime? recurrenceEnd,
    int? color,
    String? description,
    String? url,
    String? icon,
    DateTime? createdAt,
  }) {
    return ScheduleEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      recurrence: recurrence ?? this.recurrence,
      recurrenceEnd: recurrenceEnd ?? this.recurrenceEnd,
      color: color ?? this.color,
      description: description ?? this.description,
      url: url ?? this.url,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
