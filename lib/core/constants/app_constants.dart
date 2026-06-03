import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFF97316);
  static const Color secondary = Color(0xFFFFEDD5);
  static const Color background = Color(0xFFFFFBF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFF97316);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color greenAccent = success;
  static const Color yellowAccent = warning;
  static const Color blueAccent = Color(0xFF2563EB);
  static const Color purpleAccent = Color(0xFF7C3AED);
  static const Color pinkAccent = Color(0xFFDB2777);
  static const Color orangeAccent = primary;
  static const Color tealAccent = Color(0xFF0D9488);
}

class AppStyle {
  static const double borderRadius = 12.0;
  static const double borderWidth = 2.0;
  static const Offset shadowOffset = Offset(4, 4);
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
}

class NotificationTags {
  static const String social = 'social';
  static const String study = 'study';
  static const String task = 'task';
  static const String schedule = 'schedule';
}

class AchievementTypes {
  static const String studyTime = 'study_time';
  static const String streak = 'streak';
  static const String taskDone = 'task_done';
}
