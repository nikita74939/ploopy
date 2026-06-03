import 'package:isar/isar.dart';
import '../../domain/entities/schedule_entity.dart';

part 'schedule_model.g.dart';

@collection
class ScheduleModel {
  Id id = Isar.autoIncrement;

  late String name;
  late DateTime startTime;
  late DateTime endTime;
  String? location;
  String? description;
  String? link;
  late int color;
  String? iconName;

  @enumerated
  RepeatType repeatType = RepeatType.none;

  DateTime? repeatUntil;

  late DateTime createdAt;
  late String userId;
  int? remoteId;
  String syncState = 'synced';
  DateTime? deletedAt;

  ScheduleModel();

  factory ScheduleModel.create({
    required String name,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? description,
    String? link,
    int? color,
    String? iconName,
    RepeatType? repeatType,
    DateTime? repeatUntil,
    required String userId,
  }) {
    return ScheduleModel()
      ..name = name
      ..startTime = startTime
      ..endTime = endTime
      ..location = location
      ..description = description
      ..link = link
      ..color = color ?? 0xFF6C63FF
      ..iconName = iconName ?? 'event'
      ..repeatType = repeatType ?? RepeatType.none
      ..repeatUntil = repeatUntil
      ..createdAt = DateTime.now()
      ..userId = userId
      ..syncState = 'pendingCreate';
  }

  /// Convert RepeatType enum to entity string
  static String _repeatTypeToString(RepeatType type) {
    switch (type) {
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekly:
        return 'Weekly';
      case RepeatType.monthly:
        return 'Monthly';
      case RepeatType.none:
        return 'None';
    }
  }

  /// Convert entity recurrence string to RepeatType enum
  static RepeatType _stringToRepeatType(String value) {
    switch (value) {
      case 'Daily':
        return RepeatType.daily;
      case 'Weekly':
        return RepeatType.weekly;
      case 'Monthly':
        return RepeatType.monthly;
      default:
        return RepeatType.none;
    }
  }

  /// Map ScheduleModel → ScheduleEntity
  ScheduleEntity toEntity() {
    return ScheduleEntity(
      id: id,
      userId: userId,
      name: name,
      startTime: startTime,
      endTime: endTime,
      recurrence: _repeatTypeToString(repeatType),
      recurrenceEnd: repeatUntil,
      location: location,
      color: color,
      description: description,
      url: link,
      icon: iconName ?? 'event',
      createdAt: createdAt,
    );
  }

  /// Map ScheduleEntity → ScheduleModel
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel()
      ..id = (json['id'] as num).toInt()
      ..remoteId = (json['id'] as num).toInt()
      ..userId = json['user_id'] as String
      ..name = json['name'] as String
      ..startTime = DateTime.parse(json['start_time'] as String).toLocal()
      ..endTime = DateTime.parse(json['end_time'] as String).toLocal()
      ..location = json['location'] as String?
      ..description = json['description'] as String?
      ..link = json['link'] as String?
      ..color = (json['color'] as num?)?.toInt() ?? 0xFFFF7600
      ..iconName = json['icon_name'] as String? ?? 'event'
      ..repeatType = _stringToRepeatType(
        json['repeat_type'] as String? ?? 'None',
      )
      ..repeatUntil = json['repeat_until'] == null
          ? null
          : DateTime.parse(json['repeat_until'] as String).toLocal()
      ..createdAt = DateTime.parse(json['created_at'] as String).toLocal()
      ..syncState = 'synced'
      ..deletedAt = null;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      'location': location,
      'description': description,
      'link': link,
      'color': color,
      'iconName': iconName,
      'repeatType': _repeatTypeToString(repeatType),
      'repeatUntil': repeatUntil?.toUtc().toIso8601String(),
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory ScheduleModel.fromEntity(ScheduleEntity entity) {
    return ScheduleModel()
      ..id = entity.id > 0 ? entity.id : Isar.autoIncrement
      ..name = entity.name
      ..startTime = entity.startTime
      ..endTime = entity.endTime
      ..location = entity.location
      ..description = entity.description
      ..link = entity.url
      ..color = entity.color
      ..iconName = entity.icon
      ..repeatType = _stringToRepeatType(entity.recurrence)
      ..repeatUntil = entity.recurrenceEnd
      ..createdAt = entity.createdAt
      ..userId = entity.userId
      ..remoteId = entity.id > 0 ? entity.id : null
      ..syncState = 'pendingCreate';
  }
}

enum RepeatType { none, daily, weekly, monthly }
