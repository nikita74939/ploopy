import 'package:isar/isar.dart';

import '../../domain/repositories/task_repository.dart';
import '../../domain/entities/task_entity.dart';
import '../datasources/task_local_data_source.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<TaskEntity>> getTasksByDate(DateTime date, String userId) async {
    await _syncPending(userId);
    try {
      final remoteTasks = await remoteDataSource.getTasksByUser(userId);
      await localDataSource.cacheRemoteTasks(userId, remoteTasks);
    } catch (_) {
      // Offline: local cache remains the source of truth.
    }
    final tasks = await localDataSource.getTasksByDate(date, userId);
    return tasks.map(_toEntity).toList();
  }

  @override
  Future<List<TaskEntity>> getAllTasks(String userId) async {
    final tasks = await _getFreshOrCachedTasks(userId);
    return tasks.map(_toEntity).toList();
  }

  @override
  Future<List<TaskEntity>> getTasksByUser(String userId) async {
    final tasks = await _getFreshOrCachedTasks(userId);
    return tasks.map(_toEntity).toList();
  }

  @override
  Future<TaskEntity?> getTaskById(int id, String userId) async {
    await _syncPending(userId);
    final task = await localDataSource.getTaskById(id, userId);
    return task == null ? null : _toEntity(task);
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    final model = _fromEntity(task)..syncState = 'pendingCreate';
    await localDataSource.addTask(model);
    await _syncPending(task.userId);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final existing = await localDataSource.getTaskById(task.id, task.userId);
    final model = _fromEntity(task)
      ..remoteId = existing?.remoteId ?? (task.id > 0 ? task.id : null)
      ..syncState = existing?.syncState == 'pendingCreate'
          ? 'pendingCreate'
          : 'pendingUpdate';
    await localDataSource.updateTask(model);
    await _syncPending(task.userId);
  }

  @override
  Future<void> deleteTask(int id, String userId) async {
    await localDataSource.deleteTask(id, userId);
    await _syncPending(userId);
  }

  @override
  Future<List<TaskEntity>> getPinnedTasks(String userId) async {
    await _syncPending(userId);
    final tasks = await localDataSource.getPinnedTasks(userId);
    return tasks.map(_toEntity).toList();
  }

  @override
  Future<void> toggleTaskCompletion(int id, String userId) async {
    await localDataSource.toggleTaskCompletion(id, userId);
    await _syncPending(userId);
  }

  @override
  Future<void> toggleTaskPin(int id, String userId) async {
    await localDataSource.toggleTaskPin(id, userId);
    await _syncPending(userId);
  }

  Future<List<TaskModel>> _getFreshOrCachedTasks(String userId) async {
    await _syncPending(userId);
    try {
      final remoteTasks = await remoteDataSource.getTasksByUser(userId);
      await localDataSource.cacheRemoteTasks(userId, remoteTasks);
    } catch (_) {
      // Offline or backend unavailable: use local storage.
    }
    return localDataSource.getTasksByUser(userId);
  }

  Future<void> _syncPending(String userId) async {
    final pendingTasks = await localDataSource.getPendingTasks(userId);
    for (final task in pendingTasks) {
      try {
        if (task.syncState == 'pendingCreate') {
          final synced = await remoteDataSource.addTask(task);
          if (task.id != synced.id) {
            await localDataSource.deleteLocalTask(task.id);
          }
          await localDataSource.putTask(synced);
        } else if (task.syncState == 'pendingUpdate') {
          final remoteId = task.remoteId ?? task.id;
          final synced = await remoteDataSource.updateTask(
            task..remoteId = remoteId,
          );
          if (task.id != synced.id) {
            await localDataSource.deleteLocalTask(task.id);
          }
          await localDataSource.putTask(synced);
        } else if (task.syncState == 'pendingDelete') {
          final remoteId = task.remoteId ?? task.id;
          await remoteDataSource.deleteTask(remoteId, userId);
          await localDataSource.deleteLocalTask(task.id);
        }
      } catch (_) {
        return;
      }
    }
  }

  TaskEntity _toEntity(TaskModel model) {
    return TaskEntity(
      id: model.id,
      userId: model.userId,
      name: model.name,
      subject: model.subject,
      deadline: model.deadline,
      details: model.details,
      color: model.color,
      iconName: model.iconName,
      isPinned: model.isPinned,
      isCompleted: model.isCompleted,
      createdAt: model.createdAt,
    );
  }

  TaskModel _fromEntity(TaskEntity entity) {
    return TaskModel()
      ..id = entity.id > 0 ? entity.id : Isar.autoIncrement
      ..remoteId = entity.id > 0 ? entity.id : null
      ..userId = entity.userId
      ..name = entity.name
      ..subject = entity.subject
      ..deadline = entity.deadline
      ..details = entity.details
      ..color = entity.color
      ..iconName = entity.iconName
      ..isPinned = entity.isPinned
      ..isCompleted = entity.isCompleted
      ..createdAt = entity.createdAt;
  }
}
