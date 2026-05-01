import 'dart:async';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ploopy/features/scanner/domain/models/scanned_doc_isar_model.dart';
import 'package:ploopy/features/schedule/domain/models/schedule_model.dart';
import 'package:ploopy/features/schedule/domain/models/task_model.dart';
import 'package:ploopy/features/study_desk/domain/models/achievement_model.dart';
import 'package:ploopy/features/study_desk/domain/models/streak_model.dart';
import 'package:ploopy/features/study_desk/domain/models/study_session_model.dart';

class LocalDbService {
  static Isar? _isar;

  // Singleton — panggil sekali di main.dart
  static Future<Isar> get instance async {
    if (_isar != null && _isar!.isOpen) return _isar!;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([
      ScheduleItemSchema,
      TaskItemSchema,
      StudySessionSchema,
      StreakRecordSchema,
      AchievementItemSchema,
      ScannedDocIsarSchema,
    ], directory: dir.path);
    return _isar!;
  }

  // ════════════════════════════════════════════════
  //  SCHEDULE
  // ════════════════════════════════════════════════

  static Future<List<ScheduleItem>> getScheduleByDate(DateTime date) async {
    final db = await instance;
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return db.scheduleItems
        .filter()
        .startDateBetween(start, end)
        .sortByStartHour()
        .findAll();
  }

  static Future<void> saveSchedule(ScheduleItem item) async {
    final db = await instance;
    await db.writeTxn(() => db.scheduleItems.put(item));
  }

  static Future<void> toggleScheduleDone(int id) async {
    final db = await instance;
    final item = await db.scheduleItems.get(id);
    if (item == null) return;
    item.isDone = !item.isDone;
    await db.writeTxn(() => db.scheduleItems.put(item));
  }

  static Future<void> deleteSchedule(int id) async {
    final db = await instance;
    await db.writeTxn(() => db.scheduleItems.delete(id));
  }

  // ════════════════════════════════════════════════
  //  TASK
  // ════════════════════════════════════════════════

  static Future<List<TaskItem>> getTasks({bool? isDone}) async {
    final db = await instance;
    if (isDone == null) {
      return db.taskItems.where().sortByDueDate().findAll();
    }
    return db.taskItems
        .filter()
        .isDoneEqualTo(isDone)
        .sortByDueDate()
        .findAll();
  }

  static Future<void> saveTask(TaskItem item) async {
    final db = await instance;
    await db.writeTxn(() => db.taskItems.put(item));
  }

  static Future<void> toggleTaskDone(int id) async {
    final db = await instance;
    final item = await db.taskItems.get(id);
    if (item == null) return;
    item.isDone = !item.isDone;
    await db.writeTxn(() => db.taskItems.put(item));
  }

  static Future<void> deleteTask(int id) async {
    final db = await instance;
    await db.writeTxn(() => db.taskItems.delete(id));
  }

  // ════════════════════════════════════════════════
  //  STUDY SESSION (study time)
  // ════════════════════════════════════════════════

  static Future<void> saveStudySession(StudySession session) async {
    final db = await instance;
    await db.writeTxn(() => db.studySessions.put(session));
  }

  /// Total menit belajar hari ini
  static Future<int> getTodayStudyMinutes() async {
    final db = await instance;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final sessions =
        await db.studySessions.filter().dateBetween(start, end).findAll();
    return sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
  }

  /// Total menit per subject (untuk chart)
  static Future<Map<String, int>> getStudyMinutesBySubject() async {
    final db = await instance;
    final all = await db.studySessions.where().findAll();
    final Map<String, int> result = {};
    for (final s in all) {
      result[s.subject] = (result[s.subject] ?? 0) + s.durationMinutes;
    }
    return result;
  }

  // ════════════════════════════════════════════════
  //  STREAK
  // ════════════════════════════════════════════════

  static Future<StreakRecord?> getLatestStreak() async {
    final db = await instance;
    return db.streakRecords.where().sortByDateDesc().findFirst();
  }

  static Future<void> updateStreak() async {
    final db = await instance;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final latest = await getLatestStreak();

    // Sudah dicatat hari ini? skip
    if (latest != null) {
      final latestDay = DateTime(
        latest.date.year,
        latest.date.month,
        latest.date.day,
      );
      if (latestDay == today) return;
    }

    final yesterday = today.subtract(const Duration(days: 1));
    final isConsecutive =
        latest != null &&
        DateTime(latest.date.year, latest.date.month, latest.date.day) ==
            yesterday;

    final newCurrent = isConsecutive ? (latest.currentStreak + 1) : 1;  // ← Remove !
    final newLongest =
        isConsecutive
            ? (newCurrent > (latest.longestStreak)  // ← Remove ! here too
                ? newCurrent
                : latest.longestStreak)
            : (latest?.longestStreak ?? 1);

    final record =
        StreakRecord()
          ..date = now
          ..currentStreak = newCurrent
          ..longestStreak = newLongest
          ..completedToday = true;

    await db.writeTxn(() => db.streakRecords.put(record));
  }

  // ════════════════════════════════════════════════
  //  ACHIEVEMENT
  // ════════════════════════════════════════════════

  static Future<List<AchievementItem>> getAchievements() async {
    final db = await instance;
    return db.achievementItems.where().findAll();
  }

  static Future<void> unlockAchievement(int id) async {
    final db = await instance;
    final item = await db.achievementItems.get(id);
    if (item == null || item.isUnlocked) return;
    item.isUnlocked = true;
    item.unlockedAt = DateTime.now();
    await db.writeTxn(() => db.achievementItems.put(item));
  }

  static Future<void> seedAchievements() async {
    final db = await instance;
    final existing = await db.achievementItems.count();
    if (existing > 0) return; // sudah ada, skip

    final seeds = [
      AchievementItem()
        ..title = 'Fire Starter'
        ..desc = 'Streak 7 hari'
        ..iconCodePoint =
            '0xe25d' // Icons.local_fire_department
        ..colorValue = 0xFFFF6B6B
        ..isUnlocked = false,
      AchievementItem()
        ..title = 'Rising Star'
        ..desc = '10 aktivitas'
        ..iconCodePoint = '0xe62d'
        ..colorValue = 0xFFFFD166
        ..isUnlocked = false,
      AchievementItem()
        ..title = 'Brain Master'
        ..desc = '50 jam belajar'
        ..iconCodePoint = '0xe4a0'
        ..colorValue = 0xFFB79CED
        ..isUnlocked = false,
      AchievementItem()
        ..title = 'Champion'
        ..desc = 'Top 10 global'
        ..iconCodePoint = '0xe1c9'
        ..colorValue = 0xFF4D96FF
        ..isUnlocked = false,
      AchievementItem()
        ..title = 'Diamond'
        ..desc = 'Premium user'
        ..iconCodePoint = '0xe19f'
        ..colorValue = 0xFF6BCB77
        ..isUnlocked = false,
    ];

    await db.writeTxn(() => db.achievementItems.putAll(seeds));
  }

  // ════════════════════════════════════════════════
  //  SCANNED DOC & OCR
  // ════════════════════════════════════════════════

  static Future<List<ScannedDocIsar>> getAllScannedDocs() async {
    final db = await instance;
    return db.scannedDocIsars.where().sortByScannedAtDesc().findAll();
  }

  static Future<void> saveScannedDoc(ScannedDocIsar doc) async {
    final db = await instance;
    await db.writeTxn(() => db.scannedDocIsars.put(doc));
  }

  static Future<void> deleteScannedDoc(int id) async {
    final db = await instance;
    await db.writeTxn(() => db.scannedDocIsars.delete(id));
  }

  static Future<ScannedDocIsar?> getScannedDocByDocId(String docId) async {
    final db = await instance;
    return db.scannedDocIsars.filter().docIdEqualTo(docId).findFirst();
  }
}
