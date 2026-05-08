import 'package:isar/isar.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasksByDate(DateTime date, String userId);
  Future<List<TaskModel>> getAllTasks(String userId);
  Future<List<TaskModel>> getTasksByUser(String userId);
  Future<TaskModel?> getTaskById(int id, String userId);
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(int id, String userId);
  Future<List<TaskModel>> getPinnedTasks(String userId);
  Future<void> toggleTaskCompletion(int id, String userId);
  Future<void> toggleTaskPin(int id, String userId);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Isar isar;

  TaskLocalDataSourceImpl({required this.isar});

  @override
  Future<List<TaskModel>> getTasksByDate(DateTime date, String userId) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await isar.taskModels
        .filter()
        .userIdEqualTo(userId)
        .deadlineGreaterThan(startOfDay)
        .deadlineLessThan(endOfDay)
        .sortByIsPinnedDesc()
        .thenByDeadline()
        .findAll();
  }

  @override
  Future<List<TaskModel>> getAllTasks(String userId) async {
    return await isar.taskModels
        .filter()
        .userIdEqualTo(userId)
        .sortByIsPinnedDesc()
        .thenByDeadline()
        .findAll();
  }

  @override
  Future<List<TaskModel>> getTasksByUser(String userId) async {
    return await isar.taskModels
        .filter()
        .userIdEqualTo(userId)
        .sortByIsPinnedDesc()
        .thenByDeadline()
        .findAll();
  }

  @override
  Future<TaskModel?> getTaskById(int id, String userId) async {
    return await isar.taskModels
        .filter()
        .idEqualTo(id)
        .userIdEqualTo(userId)
        .findFirst();
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await isar.writeTxn(() async {
      await isar.taskModels.put(task);
    });
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await isar.writeTxn(() async {
      await isar.taskModels.put(task);
    });
  }

  @override
  Future<void> deleteTask(int id, String userId) async {
    await isar.writeTxn(() async {
      // Verifikasi task milik user sebelum hapus
      final task = await isar.taskModels
          .filter()
          .idEqualTo(id)
          .userIdEqualTo(userId)
          .findFirst();
      if (task != null) {
        await isar.taskModels.delete(id);
      }
    });
  }

  @override
  Future<List<TaskModel>> getPinnedTasks(String userId) async {
    return await isar.taskModels
        .filter()
        .userIdEqualTo(userId)
        .isPinnedEqualTo(true)
        .sortByDeadline()
        .findAll();
  }

  @override
  Future<void> toggleTaskCompletion(int id, String userId) async {
    await isar.writeTxn(() async {
      final task = await isar.taskModels
          .filter()
          .idEqualTo(id)
          .userIdEqualTo(userId)
          .findFirst();
      if (task != null) {
        task.isCompleted = !task.isCompleted;
        await isar.taskModels.put(task);
      }
    });
  }

  @override
  Future<void> toggleTaskPin(int id, String userId) async {
    await isar.writeTxn(() async {
      final task = await isar.taskModels
          .filter()
          .idEqualTo(id)
          .userIdEqualTo(userId)
          .findFirst();
      if (task != null) {
        task.isPinned = !task.isPinned;
        await isar.taskModels.put(task);
      }
    });
  }
}