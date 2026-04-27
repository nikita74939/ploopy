enum AiActionType {
  todo,
  event,
  post,
  pomodoro,
  none,
}

class AiAction {
  final AiActionType type;
  final Map<String, dynamic> data;
  final String message; // pesan dari AI

  AiAction({
    required this.type,
    required this.data,
    required this.message,
  });

  factory AiAction.none(String message) {
    return AiAction(
      type: AiActionType.none,
      data: {},
      message: message,
    );
  }

  /// Parse dari JSON yang dikembalikan AI
  factory AiAction.fromJson(Map<String, dynamic> json) {
    final typeStr = json['action_type'] as String? ?? 'none';
    final type = _parseType(typeStr);
    final data = Map<String, dynamic>.from(json['data'] ?? {});
    final message = json['message'] as String? ?? '';

    return AiAction(
      type: type,
      data: data,
      message: message,
    );
  }

  static AiActionType _parseType(String str) {
    switch (str.toLowerCase()) {
      case 'todo':
      case 'create_todo':
        return AiActionType.todo;
      case 'event':
      case 'create_event':
        return AiActionType.event;
      case 'post':
      case 'create_post':
        return AiActionType.post;
      case 'pomodoro':
      case 'start_pomodoro':
        return AiActionType.pomodoro;
      default:
        return AiActionType.none;
    }
  }

  String get title {
    switch (type) {
      case AiActionType.todo:
        return 'Tambah To-Do';
      case AiActionType.event:
        return 'Buat Event';
      case AiActionType.post:
        return 'Buat Postingan';
      case AiActionType.pomodoro:
        return 'Mulai Pomodoro';
      case AiActionType.none:
        return '';
    }
  }

  String get emoji {
    switch (type) {
      case AiActionType.todo:
        return '✅';
      case AiActionType.event:
        return '📅';
      case AiActionType.post:
        return '📝';
      case AiActionType.pomodoro:
        return '⏱️';
      case AiActionType.none:
        return '';
    }
  }
}