import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasksByDate(DateTime date, String userId);
  Future<List<TaskModel>> getAllTasks(String userId);
  Future<List<TaskModel>> getTasksByUser(String userId);
  Future<TaskModel?> getTaskById(int id, String userId);
  Future<TaskModel> addTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(int id, String userId);
  Future<List<TaskModel>> getPinnedTasks(String userId);
  Future<void> toggleTaskCompletion(int id, String userId);
  Future<void> toggleTaskPin(int id, String userId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final FlutterSecureStorage secureStorage;

  TaskRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.secureStorage,
  });

  @override
  Future<List<TaskModel>> getTasksByDate(DateTime date, String userId) async {
    final response = await client
        .get(
          _uri('/api/tasks', {
            'date': DateTime(date.year, date.month, date.day).toIso8601String(),
          }),
          headers: await _jsonHeaders(),
        )
        .timeout(const Duration(seconds: 5));
    return _taskList(_decode(response)['tasks'] as List?);
  }

  @override
  Future<List<TaskModel>> getAllTasks(String userId) => getTasksByUser(userId);

  @override
  Future<List<TaskModel>> getTasksByUser(String userId) async {
    final response = await client
        .get(_uri('/api/tasks'), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 5));
    return _taskList(_decode(response)['tasks'] as List?);
  }

  @override
  Future<TaskModel?> getTaskById(int id, String userId) async {
    final response = await client
        .get(_uri('/api/tasks/$id'), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 5));
    final data = _decode(response)['task'] as Map<String, dynamic>?;
    return data == null ? null : TaskModel.fromJson(data);
  }

  @override
  Future<TaskModel> addTask(TaskModel task) async {
    final response = await client
        .post(
          _uri('/api/tasks'),
          headers: await _jsonHeaders(),
          body: jsonEncode(task.toJson()),
        )
        .timeout(const Duration(seconds: 5));
    return TaskModel.fromJson(
      _decode(response)['task'] as Map<String, dynamic>,
    );
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    final response = await client
        .patch(
          _uri('/api/tasks/${task.remoteId ?? task.id}'),
          headers: await _jsonHeaders(),
          body: jsonEncode(task.toJson()),
        )
        .timeout(const Duration(seconds: 5));
    return TaskModel.fromJson(
      _decode(response)['task'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteTask(int id, String userId) async {
    final response = await client
        .delete(_uri('/api/tasks/$id'), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 5));
    _decode(response);
  }

  @override
  Future<List<TaskModel>> getPinnedTasks(String userId) async {
    final response = await client
        .get(
          _uri('/api/tasks', {'pinned': 'true'}),
          headers: await _jsonHeaders(),
        )
        .timeout(const Duration(seconds: 5));
    return _taskList(_decode(response)['tasks'] as List?);
  }

  @override
  Future<void> toggleTaskCompletion(int id, String userId) async {
    final current = await getTaskById(id, userId);
    if (current == null) return;

    final response = await client
        .patch(
          _uri('/api/tasks/$id/completion'),
          headers: await _jsonHeaders(),
          body: jsonEncode({'completed': !current.isCompleted}),
        )
        .timeout(const Duration(seconds: 5));
    _decode(response);
  }

  @override
  Future<void> toggleTaskPin(int id, String userId) async {
    final current = await getTaskById(id, userId);
    if (current == null) return;

    final response = await client
        .patch(
          _uri('/api/tasks/$id/pin'),
          headers: await _jsonHeaders(),
          body: jsonEncode({'pinned': !current.isPinned}),
        )
        .timeout(const Duration(seconds: 5));
    _decode(response);
  }

  List<TaskModel> _taskList(List? rows) {
    return (rows ?? [])
        .map((row) => TaskModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: query);
  }

  Future<Map<String, String>> _jsonHeaders() async {
    final token = await secureStorage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        body['message']?.toString() ?? 'Request gagal. Coba lagi.',
      );
    }

    return body;
  }
}
