import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TaskModel>> getTasksByDate(DateTime date, String userId) async {
    return await localDataSource.getTasksByDate(date, userId);
  }

  @override
  Future<List<TaskModel>> getAllTasks(String userId) async {
    return await localDataSource.getAllTasks(userId);
  }

  @override
  Future<List<TaskModel>> getTasksByUser(String userId) async {
    return await localDataSource.getTasksByUser(userId);
  }

  @override
  Future<TaskModel?> getTaskById(int id, String userId) async {
    return await localDataSource.getTaskById(id, userId);
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await localDataSource.addTask(task);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await localDataSource.updateTask(task);
  }

  @override
  Future<void> deleteTask(int id, String userId) async {
    await localDataSource.deleteTask(id, userId);
  }

  @override
  Future<List<TaskModel>> getPinnedTasks(String userId) async {
    return await localDataSource.getPinnedTasks(userId);
  }

  @override
  Future<void> toggleTaskCompletion(int id, String userId) async {
    await localDataSource.toggleTaskCompletion(id, userId);
  }

  @override
  Future<void> toggleTaskPin(int id, String userId) async {
    await localDataSource.toggleTaskPin(id, userId);
  }
}