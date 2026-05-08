import '../../data/models/task_model.dart';

abstract class TaskRepository {
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