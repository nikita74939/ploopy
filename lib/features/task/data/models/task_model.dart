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
      ..isCompleted = isCompleted // Sekarang merujuk ke parameter di atas
      ..createdAt = DateTime.now()
      ..userId = userId;
  }
}