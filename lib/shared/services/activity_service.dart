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
      final activities =
          list
              .map((e) => Activity.fromJson(e as Map<String, dynamic>))
              .toList();

      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return activities;
    } catch (_) {
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
        userAvatarUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=160&h=160&fit=crop&crop=faces',
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
    } catch (_) {
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
        likeCount:
            activity.isLiked ? activity.likeCount - 1 : activity.likeCount + 1,
      );

      list[index] = updated;

      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((a) => a.toJson()).toList();
      return await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {
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
    } catch (_) {
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

    final now = DateTime.now();
    final samples = [
      Activity(
        id: _uuid.v4(),
        userId: 'user_1',
        userName: 'Nadia Putri',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160&h=160&fit=crop&crop=faces',
        content:
            'Selesai review materi Metodologi Penelitian untuk kelas besok. Tinggal rapihin daftar pustaka dan slide presentasi.',
        imageUrl:
            'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=900&h=600&fit=crop',
        location: 'Perpustakaan Kampus',
        activityTag: 'Task complete',
        latitude: -6.8895,
        longitude: 107.6108,
        likeCount: 18,
        commentCount: 4,
        isLiked: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Activity(
        id: _uuid.v4(),
        userId: 'user_2',
        userName: 'Rafi Ramadhan',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=160&h=160&fit=crop&crop=faces',
        content:
            'Jadwal praktikum Basis Data minggu ini sudah selesai. Catatan query join aku upload malam ini buat teman satu kelompok.',
        location: 'Lab Informatika',
        activityTag: 'Schedule complete',
        latitude: -6.8950,
        longitude: 107.6080,
        likeCount: 27,
        commentCount: 9,
        isLiked: true,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      Activity(
        id: _uuid.v4(),
        userId: 'user_3',
        userName: 'Alya Maharani',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=160&h=160&fit=crop&crop=faces',
        content:
            'Butuh 2 orang lagi buat belajar bareng Statistik. Fokus latihan soal regresi linear, jam 19.00.',
        imageUrl:
            'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=900&h=600&fit=crop',
        location: 'Student Center',
        latitude: -6.9020,
        longitude: 107.6160,
        likeCount: 14,
        commentCount: 15,
        isLiked: false,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Activity(
        id: _uuid.v4(),
        userId: 'user_4',
        userName: 'Dimas Arya',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=160&h=160&fit=crop&crop=faces',
        content:
            'Akhirnya submit proposal PKM sebelum deadline. Semoga revisinya tidak terlalu banyak.',
        activityTag: 'Achievement',
        likeCount: 36,
        commentCount: 12,
        isLiked: false,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    final prefs = await SharedPreferences.getInstance();
    final jsonList = samples.map((a) => a.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }
}
