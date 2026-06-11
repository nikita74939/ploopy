import 'package:isar/isar.dart';

part 'task_model.g.dart';

@collection
class TaskModel {
  Id id = Isar.autoIncrement;

  late String name;
  String? subject;
  late DateTime deadline;
  String? details;
  late int color;
  String? iconName;
  bool isPinned = false;
  bool isCompleted = false; // Ini adalah instance member
  late DateTime createdAt;
  late String userId;
  int? remoteId;
  String syncState = 'synced';
  DateTime? deletedAt;

  TaskModel();

  factory TaskModel.create({
    required String name,
    String? subject,
    required DateTime deadline,
    String? details,
    int? color,
    String? iconName,
    bool isPinned = false,
    bool isCompleted = false, // TAMBAHKAN parameter ini di sini
    required String userId,
  }) {
    return TaskModel()
      ..name = name
      ..subject = subject
      ..deadline = deadline
      ..details = details
      ..color = color ?? 0xFF6C63FF
      ..iconName = iconName ?? 'task'
      ..isPinned = isPinned
      ..isCompleted =
          isCompleted // Sekarang merujuk ke parameter di atas
      ..createdAt = DateTime.now()
      ..userId = userId
      ..syncState = 'pendingCreate';
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel()
      ..id = (json['id'] as num).toInt()
      ..remoteId = (json['id'] as num).toInt()
      ..userId = json['user_id'] as String
      ..name = json['name'] as String
      ..subject = json['subject'] as String?
      ..deadline = DateTime.parse(json['deadline'] as String).toLocal()
      ..details = json['details'] as String?
      ..color = (json['color'] as num?)?.toInt() ?? 0xFFFF7600
      ..iconName = json['icon_name'] as String? ?? 'task'
      ..isPinned = json['is_pinned'] as bool? ?? false
      ..isCompleted = json['is_completed'] as bool? ?? false
      ..createdAt = DateTime.parse(json['created_at'] as String).toLocal()
      ..syncState = 'synced'
      ..deletedAt = null;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'subject': subject,
      'deadline': deadline.toUtc().toIso8601String(),
      'details': details,
      'color': color,
      'iconName': iconName,
      'isPinned': isPinned,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}
