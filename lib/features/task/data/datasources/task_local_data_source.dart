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
  Future<List<TaskModel>> getPendingTasks(String userId);
  Future<void> cacheRemoteTasks(String userId, List<TaskModel> tasks);
  Future<void> putTask(TaskModel task);
  Future<void> deleteLocalTask(int id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Isar isar;

  TaskLocalDataSourceImpl({required this.isar});

  @override
  Future<List<TaskModel>> getTasksByDate(DateTime date, String userId) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final tasks = await isar.taskModels
        .filter()
        .userIdEqualTo(userId)
        .deadlineGreaterThan(startOfDay, include: true)
        .deadlineLessThan(endOfDay)
        .findAll();
    return _visibleSorted(tasks);
  }

  @override
  Future<List<TaskModel>> getAllTasks(String userId) async {
    final tasks = await isar.taskModels
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    return _visibleSorted(tasks);
  }

  @override
  Future<List<TaskModel>> getTasksByUser(String userId) async {
    final tasks = await isar.taskModels
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    return _visibleSorted(tasks);
  }

  @override
  Future<TaskModel?> getTaskById(int id, String userId) async {
    final task = await isar.taskModels
        .filter()
        .idEqualTo(id)
        .userIdEqualTo(userId)
        .findFirst();
    return _isVisible(task) ? task : null;
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
        if (task.syncState == 'pendingCreate') {
          await isar.taskModels.delete(id);
        } else {
          task
            ..remoteId = task.remoteId ?? task.id
            ..syncState = 'pendingDelete'
            ..deletedAt = DateTime.now();
          await isar.taskModels.put(task);
        }
      }
    });
  }

  @override
  Future<List<TaskModel>> getPinnedTasks(String userId) async {
    final tasks = await isar.taskModels
        .filter()
        .userIdEqualTo(userId)
        .isPinnedEqualTo(true)
        .findAll();
    return _visibleSorted(tasks);
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
        if (_isSynced(task)) task.syncState = 'pendingUpdate';
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
        if (_isSynced(task)) task.syncState = 'pendingUpdate';
        await isar.taskModels.put(task);
      }
    });
  }

  @override
  Future<List<TaskModel>> getPendingTasks(String userId) async {
    final tasks = await isar.taskModels
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    return tasks.where((task) => task.syncState.startsWith('pending')).toList();
  }

  @override
  Future<void> cacheRemoteTasks(String userId, List<TaskModel> tasks) async {
    await isar.writeTxn(() async {
      final localTasks = await isar.taskModels
          .filter()
          .userIdEqualTo(userId)
          .findAll();
      final dirtyRemoteIds = localTasks
          .where((task) => !_isSynced(task) && task.remoteId != null)
          .map((task) => task.remoteId)
          .toSet();
      final dirtyLocalIds = localTasks
          .where((task) => !_isSynced(task))
          .map((task) => task.id)
          .toSet();

      for (final task in localTasks) {
        if (_isSynced(task)) {
          await isar.taskModels.delete(task.id);
        }
      }

      for (final task in tasks) {
        final targetId = task.remoteId ?? task.id;
        if (dirtyRemoteIds.contains(targetId) ||
            dirtyLocalIds.contains(targetId)) {
          continue;
        }
        task
          ..id = targetId
          ..remoteId = targetId
          ..syncState = 'synced'
          ..deletedAt = null;
        await isar.taskModels.put(task);
      }
    });
  }

  @override
  Future<void> putTask(TaskModel task) async {
    await isar.writeTxn(() async {
      await isar.taskModels.put(task);
    });
  }

  @override
  Future<void> deleteLocalTask(int id) async {
    await isar.writeTxn(() async {
      await isar.taskModels.delete(id);
    });
  }

  bool _isVisible(TaskModel? task) {
    return task != null &&
        task.syncState != 'pendingDelete' &&
        task.deletedAt == null;
  }

  bool _isSynced(TaskModel task) {
    return task.syncState.isEmpty || task.syncState == 'synced';
  }

  List<TaskModel> _visibleSorted(List<TaskModel> tasks) {
    final visible = tasks.where(_isVisible).toList();
    visible.sort((a, b) {
      final pinned = b.isPinned.toString().compareTo(a.isPinned.toString());
      if (pinned != 0) return pinned;
      return a.deadline.compareTo(b.deadline);
    });
    return visible;
  }
}
