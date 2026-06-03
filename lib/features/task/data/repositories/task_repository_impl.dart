import '../../domain/repositories/task_repository.dart';
import '../../domain/entities/task_entity.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TaskEntity>> getTasksByDate(DateTime date, String userId) async {
    final tasks = await remoteDataSource.getTasksByDate(date, userId);
    return tasks.map(_toEntity).toList();
  }

  @override
  Future<List<TaskEntity>> getAllTasks(String userId) async {
    final tasks = await remoteDataSource.getAllTasks(userId);
    return tasks.map(_toEntity).toList();
  }

  @override
  Future<List<TaskEntity>> getTasksByUser(String userId) async {
    final tasks = await remoteDataSource.getTasksByUser(userId);
    return tasks.map(_toEntity).toList();
  }

  @override
  Future<TaskEntity?> getTaskById(int id, String userId) async {
    final task = await remoteDataSource.getTaskById(id, userId);
    return task == null ? null : _toEntity(task);
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    await remoteDataSource.addTask(_fromEntity(task));
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    await remoteDataSource.updateTask(_fromEntity(task));
  }

  @override
  Future<void> deleteTask(int id, String userId) async {
    await remoteDataSource.deleteTask(id, userId);
  }

  @override
  Future<List<TaskEntity>> getPinnedTasks(String userId) async {
    final tasks = await remoteDataSource.getPinnedTasks(userId);
    return tasks.map(_toEntity).toList();
  }

  @override
  Future<void> toggleTaskCompletion(int id, String userId) async {
    await remoteDataSource.toggleTaskCompletion(id, userId);
  }

  @override
  Future<void> toggleTaskPin(int id, String userId) async {
    await remoteDataSource.toggleTaskPin(id, userId);
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
      ..id = entity.id
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
