import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getTasksByDate(DateTime date, String userId);
  Future<List<TaskEntity>> getAllTasks(String userId);
  Future<List<TaskEntity>> getTasksByUser(String userId);
  Future<TaskEntity?> getTaskById(int id, String userId);
  Future<void> addTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(int id, String userId);
  Future<List<TaskEntity>> getPinnedTasks(String userId);
  Future<void> toggleTaskCompletion(int id, String userId);
  Future<void> toggleTaskPin(int id, String userId);
}
