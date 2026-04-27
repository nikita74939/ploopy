import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../features/todo/domain/todo_model.dart';

class TodoService {
  static const String _storageKey = 'ploopy_todos';
  static const _uuid = Uuid();

  /// Ambil semua todos
  static Future<List<Todo>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr == null || jsonStr.isEmpty) return [];

      final List<dynamic> list = jsonDecode(jsonStr);
      return list
          .map((e) => Todo.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error loading todos: $e');
      return [];
    }
  }

  /// Simpan ke storage
  static Future<bool> _saveAll(List<Todo> todos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = todos.map((t) => t.toJson()).toList();
      return await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      print('❌ Error saving todos: $e');
      return false;
    }
  }

  /// Tambah todo baru
  static Future<Todo> create({
    required String title,
    String description = '',
    DateTime? dueDate,
    String? dueTime,
    TodoPriority priority = TodoPriority.medium,
    TodoCategory category = TodoCategory.personal,
  }) async {
    final todo = Todo(
      id: _uuid.v4(),
      title: title.trim(),
      description: description.trim(),
      dueDate: dueDate,
      dueTime: dueTime,
      priority: priority,
      category: category,
      createdAt: DateTime.now(),
    );

    final todos = await getAll();
    todos.add(todo);
    await _saveAll(todos);
    return todo;
  }

  /// Update todo
  static Future<bool> update(Todo todo) async {
    final todos = await getAll();
    final index = todos.indexWhere((t) => t.id == todo.id);
    if (index == -1) return false;

    todos[index] = todo;
    return await _saveAll(todos);
  }

  /// Toggle done status
  static Future<bool> toggleDone(String id) async {
    final todos = await getAll();
    final index = todos.indexWhere((t) => t.id == id);
    if (index == -1) return false;

    todos[index] = todos[index].copyWith(isDone: !todos[index].isDone);
    return await _saveAll(todos);
  }

  /// Delete todo
  static Future<bool> delete(String id) async {
    final todos = await getAll();
    todos.removeWhere((t) => t.id == id);
    return await _saveAll(todos);
  }

  /// Delete all done todos
  static Future<bool> deleteAllDone() async {
    final todos = await getAll();
    todos.removeWhere((t) => t.isDone);
    return await _saveAll(todos);
  }

  /// Delete all
  static Future<bool> deleteAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_storageKey);
    } catch (_) {
      return false;
    }
  }
}