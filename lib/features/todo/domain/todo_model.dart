import 'package:flutter/material.dart';

enum TodoPriority { low, medium, high }

enum TodoCategory { study, personal, work, health, other }

class Todo {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final String? dueTime; // HH:mm
  final TodoPriority priority;
  final TodoCategory category;
  final bool isDone;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.dueTime,
    this.priority = TodoPriority.medium,
    this.category = TodoCategory.personal,
    this.isDone = false,
    required this.createdAt,
  });

  Todo copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    String? dueTime,
    TodoPriority? priority,
    TodoCategory? category,
    bool? isDone,
    bool clearDueDate = false,
    bool clearDueTime = false,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      dueTime: clearDueTime ? null : (dueTime ?? this.dueTime),
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate?.toIso8601String(),
        'dueTime': dueTime,
        'priority': priority.name,
        'category': category.name,
        'isDone': isDone,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'] as String)
          : null,
      dueTime: json['dueTime'] as String?,
      priority: TodoPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => TodoPriority.medium,
      ),
      category: TodoCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => TodoCategory.personal,
      ),
      isDone: json['isDone'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  // UI Helpers
  Color get priorityColor {
    switch (priority) {
      case TodoPriority.high:
        return const Color(0xFFFF6B6B);
      case TodoPriority.medium:
        return const Color(0xFFFF8C42);
      case TodoPriority.low:
        return const Color(0xFF6BCB77);
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TodoPriority.high:
        return 'Tinggi';
      case TodoPriority.medium:
        return 'Sedang';
      case TodoPriority.low:
        return 'Rendah';
    }
  }

  Color get categoryColor {
    switch (category) {
      case TodoCategory.study:
        return const Color(0xFF4D96FF);
      case TodoCategory.work:
        return const Color(0xFFB79CED);
      case TodoCategory.health:
        return const Color(0xFF6BCB77);
      case TodoCategory.personal:
        return const Color(0xFFFFD166);
      case TodoCategory.other:
        return Colors.grey.shade500;
    }
  }

  String get categoryLabel {
    switch (category) {
      case TodoCategory.study:
        return 'Belajar';
      case TodoCategory.work:
        return 'Pekerjaan';
      case TodoCategory.health:
        return 'Kesehatan';
      case TodoCategory.personal:
        return 'Pribadi';
      case TodoCategory.other:
        return 'Lainnya';
    }
  }

  String get categoryEmoji {
    switch (category) {
      case TodoCategory.study:
        return '📚';
      case TodoCategory.work:
        return '💼';
      case TodoCategory.health:
        return '💪';
      case TodoCategory.personal:
        return '💖';
      case TodoCategory.other:
        return '📌';
    }
  }

  bool get isToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isUpcoming {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dueDate!.isAfter(today);
  }

  bool get isOverdue {
    if (dueDate == null || isDone) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dueDate!.isBefore(today);
  }
}