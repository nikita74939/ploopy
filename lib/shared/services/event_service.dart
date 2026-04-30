import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../features/event/domain/event_model.dart';

class EventService {
  static const String _storageKey = 'ploopy_events';
  static const _uuid = Uuid();

  /// Get all events (upcoming first, then past)
  static Future<List<Event>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr == null || jsonStr.isEmpty) return [];

      final List<dynamic> list = jsonDecode(jsonStr);
      final events =
          list.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();

      events.sort((a, b) {
        if (a.isUpcoming && !b.isUpcoming) return -1;
        if (!a.isUpcoming && b.isUpcoming) return 1;
        return a.dateTime.compareTo(b.dateTime);
      });

      return events;
    } catch (_) {
      return [];
    }
  }

  /// Get upcoming events only
  static Future<List<Event>> getUpcoming() async {
    final all = await getAll();
    return all.where((e) => e.isUpcoming).toList();
  }

  /// Get past events
  static Future<List<Event>> getPast() async {
    final all = await getAll();
    return all.where((e) => e.isPast).toList();
  }

  /// Create new event
  static Future<Event?> create({
    required String title,
    required String description,
    required String location,
    double? latitude,
    double? longitude,
    required DateTime dateTime,
    required int maxParticipants,
    String? imageUrl,
  }) async {
    try {
      final event = Event(
        id: _uuid.v4(),
        title: title,
        description: description,
        organizerId: 'current_user', // TODO: Replace with actual user ID
        organizerName: 'Kamu', // TODO: Replace with actual user name
        location: location,
        latitude: latitude,
        longitude: longitude,
        dateTime: dateTime,
        maxParticipants: maxParticipants,
        currentParticipants: 1,
        participantIds: ['current_user'],
        imageUrl: imageUrl,
        isJoined: true,
        createdAt: DateTime.now(),
      );

      final list = await getAll();
      list.insert(0, event);

      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((e) => e.toJson()).toList();
      final saved = await prefs.setString(_storageKey, jsonEncode(jsonList));

      return saved ? event : null;
    } catch (_) {
      return null;
    }
  }

  /// Join event
  static Future<bool> join(String eventId) async {
    try {
      final list = await getAll();
      final index = list.indexWhere((e) => e.id == eventId);
      if (index == -1) return false;

      final event = list[index];
      if (event.isFull) return false;

      final updated = event.copyWith(
        currentParticipants: event.currentParticipants + 1,
        participantIds: [...event.participantIds, 'current_user'],
        isJoined: true,
      );

      list[index] = updated;

      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((e) => e.toJson()).toList();
      return await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {
      return false;
    }
  }

  /// Leave event
  static Future<bool> leave(String eventId) async {
    try {
      final list = await getAll();
      final index = list.indexWhere((e) => e.id == eventId);
      if (index == -1) return false;

      final event = list[index];
      final updated = event.copyWith(
        currentParticipants: event.currentParticipants - 1,
        participantIds:
            event.participantIds.where((id) => id != 'current_user').toList(),
        isJoined: false,
      );

      list[index] = updated;

      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((e) => e.toJson()).toList();
      return await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {
      return false;
    }
  }

  /// Delete event
  static Future<bool> delete(String eventId) async {
    try {
      final list = await getAll();
      list.removeWhere((e) => e.id == eventId);

      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((e) => e.toJson()).toList();
      return await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {
      return false;
    }
  }

  /// Get event by ID
  static Future<Event?> getById(String eventId) async {
    final list = await getAll();
    try {
      return list.firstWhere((e) => e.id == eventId);
    } catch (_) {
      return null;
    }
  }

  /// Get events created by current user
  static Future<List<Event>> getMyEvents() async {
    final list = await getAll();
    return list.where((e) => e.organizerId == 'current_user').toList();
  }

  /// Get events user has joined
  static Future<List<Event>> getJoinedEvents() async {
    final list = await getAll();
    return list.where((e) => e.isJoined).toList();
  }

  /// Add sample data for demo
  static Future<void> addSampleData() async {
    final existing = await getAll();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    final samples = [
      Event(
        id: _uuid.v4(),
        title: 'Study Group Statistik',
        description:
            'Bahas latihan regresi linear dan interpretasi output. Bawa laptop kalau mau ikut ngoding di spreadsheet.',
        organizerId: 'user_1',
        organizerName: 'Nadia Putri',
        location: 'Ruang Diskusi Perpus',
        latitude: -6.8895,
        longitude: 107.6108,
        dateTime: now.add(const Duration(days: 1, hours: 3)),
        maxParticipants: 12,
        currentParticipants: 8,
        participantIds: ['user_1', 'user_2', 'user_3', 'user_4'],
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Event(
        id: _uuid.v4(),
        title: 'Review Proposal Skripsi',
        description:
            'Sesi kecil untuk saling cek latar belakang, rumusan masalah, dan alur metode penelitian.',
        organizerId: 'user_2',
        organizerName: 'Rafi Ramadhan',
        location: 'Student Center',
        latitude: -6.8910,
        longitude: 107.6090,
        dateTime: now.add(const Duration(days: 2, hours: 5)),
        maxParticipants: 8,
        currentParticipants: 5,
        participantIds: ['user_2', 'user_5', 'user_6'],
        isJoined: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Event(
        id: _uuid.v4(),
        title: 'Workshop CV & LinkedIn',
        description:
            'Bikin CV satu halaman dan rapihin profil LinkedIn untuk apply magang semester depan.',
        organizerId: 'user_3',
        organizerName: 'Alya Maharani',
        location: 'Aula Fakultas',
        latitude: -6.8900,
        longitude: 107.6110,
        dateTime: now.add(const Duration(days: 4, hours: 7)),
        maxParticipants: 50,
        currentParticipants: 34,
        participantIds: ['user_3', 'user_7', 'user_8'],
        isJoined: false,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      Event(
        id: _uuid.v4(),
        title: 'Diskusi Project Mobile',
        description:
            'Check-in progress final project: UI, database lokal, dan integrasi API. Cocok untuk yang lagi stuck.',
        organizerId: 'user_4',
        organizerName: 'Dimas Arya',
        location: 'Online via Meet',
        dateTime: now.add(const Duration(days: 5, hours: 2)),
        maxParticipants: 10,
        currentParticipants: 6,
        participantIds: ['user_4', 'user_9'],
        isJoined: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Event(
        id: _uuid.v4(),
        title: 'Simulasi Presentasi UAS',
        description:
            'Latihan presentasi 7 menit, feedback dari teman, dan cek slide biar lebih padat.',
        organizerId: 'user_5',
        organizerName: 'Mira Lestari',
        location: 'Lab Multimedia',
        latitude: -6.8880,
        longitude: 107.6120,
        dateTime: now.add(const Duration(days: 7, hours: 1)),
        maxParticipants: 15,
        currentParticipants: 11,
        participantIds: ['user_5', 'user_10'],
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];

    final prefs = await SharedPreferences.getInstance();
    final jsonList = samples.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }
}
