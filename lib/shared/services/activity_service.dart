import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../features/social/domain/activity_model.dart';

class ActivityService {
  static const String _storageKey = 'ploopy_activities';
  static const _uuid = Uuid();

  /// Get all activities (newest first)
  static Future<List<Activity>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr == null || jsonStr.isEmpty) return [];

      final List<dynamic> list = jsonDecode(jsonStr);
      final activities = list
          .map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList();

      // Sort by newest first
      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return activities;
    } catch (e) {
      print('❌ Error loading activities: $e');
      return [];
    }
  }

  /// Create new activity
  static Future<Activity?> create({
    required String content,
    String? imageUrl,
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final activity = Activity(
        id: _uuid.v4(),
        userId: 'current_user', // TODO: Replace with actual user ID
        userName: 'Kamu', // TODO: Replace with actual user name
        content: content,
        imageUrl: imageUrl,
        location: location,
        latitude: latitude,
        longitude: longitude,
        likeCount: 0,
        commentCount: 0,
        isLiked: false,
        createdAt: DateTime.now(),
      );

      final list = await getAll();
      list.insert(0, activity);

      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((a) => a.toJson()).toList();
      final saved = await prefs.setString(_storageKey, jsonEncode(jsonList));

      return saved ? activity : null;
    } catch (e) {
      print('❌ Error creating activity: $e');
      return null;
    }
  }

  /// Toggle like on activity
  static Future<bool> toggleLike(String activityId) async {
    try {
      final list = await getAll();
      final index = list.indexWhere((a) => a.id == activityId);
      if (index == -1) return false;

      final activity = list[index];
      final updated = activity.copyWith(
        isLiked: !activity.isLiked,
        likeCount: activity.isLiked
            ? activity.likeCount - 1
            : activity.likeCount + 1,
      );

      list[index] = updated;

      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((a) => a.toJson()).toList();
      return await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      print('❌ Error toggling like: $e');
      return false;
    }
  }

  /// Delete activity
  static Future<bool> delete(String activityId) async {
    try {
      final list = await getAll();
      list.removeWhere((a) => a.id == activityId);

      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((a) => a.toJson()).toList();
      return await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      print('❌ Error deleting activity: $e');
      return false;
    }
  }

  /// Get activity by ID
  static Future<Activity?> getById(String activityId) async {
    final list = await getAll();
    try {
      return list.firstWhere((a) => a.id == activityId);
    } catch (_) {
      return null;
    }
  }

  /// Add sample data for demo
  static Future<void> addSampleData() async {
    final existing = await getAll();
    if (existing.isNotEmpty) return;

    final samples = [
      Activity(
        id: _uuid.v4(),
        userId: 'user_1',
        userName: 'Andi Pratama',
        content: 'Baru aja selesai belajar Kalkulus 2 di perpustakaan kampus. Fokus banget 3 jam! 📚✨',
        location: 'Perpustakaan Unpad',
        latitude: -6.8895,
        longitude: 107.6108,
        likeCount: 24,
        commentCount: 8,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Activity(
        id: _uuid.v4(),
        userId: 'user_2',
        userName: 'Siti Rahayu',
        content: 'Pomodoro session berhasil! 4 cycle selesai. Feeling productive today 💪🍅',
        location: 'Kos Green Garden',
        latitude: -6.8950,
        longitude: 107.6080,
        likeCount: 18,
        commentCount: 5,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Activity(
        id: _uuid.v4(),
        userId: 'user_3',
        userName: 'Budi Santoso',
        content: 'Ada yang mau ikut study group untuk Statistik besok pagi? ☕📊',
        location: 'Kedai Kopi Dago',
        latitude: -6.9020,
        longitude: 107.6160,
        likeCount: 12,
        commentCount: 15,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Activity(
        id: _uuid.v4(),
        userId: 'user_4',
        userName: 'Rina Wulandari',
        content: 'Finally paham juga rumus integral parsial! Terima kasih tutorial dari YouTube 🎬',
        location: 'Ruang Lab FT',
        latitude: -6.8910,
        longitude: 107.6090,
        likeCount: 31,
        commentCount: 12,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    for (final activity in samples) {
      final list = await getAll();
      list.insert(0, activity);
      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((a) => a.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    }
  }
}