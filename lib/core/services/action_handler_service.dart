import '../../features/ai/domain/ai_action.dart';

class ActionHandlerService {
  /// Execute action setelah user confirm
  static Future<ActionResult> execute(AiAction action) async {
    try {
      switch (action.type) {
        case AiActionType.todo:
          return await _createTodo(action.data);
        case AiActionType.event:
          return await _createEvent(action.data);
        case AiActionType.post:
          return await _createPost(action.data);
        case AiActionType.pomodoro:
          return await _startPomodoro(action.data);
        case AiActionType.none:
          return ActionResult.error('No action to execute');
      }
    } catch (e) {
      return ActionResult.error('Gagal: $e');
    }
  }

  static Future<ActionResult> _createTodo(Map<String, dynamic> data) async {
    // Simulate async (nanti bisa pakai SharedPreferences/Hive)
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: Integrate with real to-do storage
    print('📝 Todo created: $data');

    return ActionResult.success(
      'To-do berhasil ditambahkan! ✅',
      data,
    );
  }

  static Future<ActionResult> _createEvent(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('📅 Event created: $data');

    return ActionResult.success(
      'Event berhasil dibuat! 📅',
      data,
    );
  }

  static Future<ActionResult> _createPost(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('📝 Post created: $data');

    return ActionResult.success(
      'Post berhasil diupload! ✨',
      data,
    );
  }

  static Future<ActionResult> _startPomodoro(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('⏱️ Pomodoro started: $data');

    return ActionResult.success(
      'Pomodoro dimulai! ⏱️',
      data,
    );
  }
}

class ActionResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  ActionResult({
    required this.success,
    required this.message,
    this.data,
  });

  factory ActionResult.success(String message, [Map<String, dynamic>? data]) {
    return ActionResult(success: true, message: message, data: data);
  }

  factory ActionResult.error(String message) {
    return ActionResult(success: false, message: message);
  }
}