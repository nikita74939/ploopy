import 'package:isar/isar.dart';

part 'task_model.g.dart';

@Collection()
class TaskItem {
  Id id = Isar.autoIncrement;

  late String title;
  late String subject;    
  late int colorValue;
  late String iconCodePoint;
  late bool isDone;
  late String due;   
  late DateTime dueDate;
  late DateTime createdAt;
}