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
      final events = list
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();

      // Sort: upcoming first, then by date
      events.sort((a, b) {
        if (a.isUpcoming && !b.isUpcoming) return -1;
        if (!a.isUpcoming && b.isUpcoming) return 1;
        return a.dateTime.compareTo(b.dateTime);
      });

      return events;
    } catch (e) {
      print('❌ Error loading events: $e');
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
        currentParticipants: 1, // Organizer counts as participant
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
    } catch (e) {
      print('❌ Error creating event: $e');
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
    } catch (e) {
      print('❌ Error joining event: $e');
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
    } catch (e) {
      print('❌ Error leaving event: $e');
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
    } catch (e) {
      print('❌ Error deleting event: $e');
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
        title: 'Study Group Kalkulus',
        description:
            'Halo semua! Aku mau bikin study group buat bahas Kalkulus 2, fokus ke integral dan turunan. Yang mau join langsung aja ya!',
        organizerId: 'user_1',
        organizerName: 'Andi Pratama',
        location: 'Perpustakaan Unpad Lt.2',
        latitude: -6.8895,
        longitude: 107.6108,
        dateTime: now.add(const Duration(days: 1, hours: 10)),
        maxParticipants: 10,
        currentParticipants: 6,
        participantIds: ['user_1', 'user_2', 'user_3', 'user_4', 'user_5', 'user_6'],
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Event(
        id: _uuid.v4(),
        title: 'Bootcamp Programming',
        description:
            'Bootcamp intensif Flutter untuk pemula. Akan membahas widget, state management, dan deployment. Bring your own laptop!',
        organizerId: 'user_2',
        organizerName: 'Siti Rahayu',
        location: 'Gedung Lab Teknik Informatika',
        latitude: -6.8910,
        longitude: 107.6090,
        dateTime: now.add(const Duration(days: 3, hours: 14)),
        maxParticipants: 30,
        currentParticipants: 18,
        participantIds: ['user_2', 'user_7', 'user_8'],
        isJoined: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Event(
        id: _uuid.v4(),
        title: 'Mabar Mobile Legends',
        description:
            'Mabar ML santai, ranking Epic ke Legend. Butuh support sama tank. No rage, have fun! 🎮',
        organizerId: 'user_3',
        organizerName: 'Budi Santoso',
        location: 'Online - Discord',
        latitude: null,
        longitude: null,
        dateTime: now.add(const Duration(hours: 6)),
        maxParticipants: 5,
        currentParticipants: 4,
        participantIds: ['user_3', 'user_9', 'user_10', 'user_11'],
        isJoined: false,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      Event(
        id: _uuid.v4(),
        title: 'Workshop Public Speaking',
        description:
            'Workshop gratis tentang dasar-dasar public speaking. Cocok untuk yang mau提高 confidence saat presentasi!',
        organizerId: 'user_4',
        organizerName: 'Rina Wulandari',
        location: 'Aula Utama Student Center',
        latitude: -6.8900,
        longitude: 107.6110,
        dateTime: now.add(const Duration(days: 5, hours: 9)),
        maxParticipants: 50,
        currentParticipants: 32,
        participantIds: ['user_4', 'user_12', 'user_13'],
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Event(
        id: _uuid.v4(),
        title: 'Temu Alumni 2024',
        description:
            'Reuni tahunan angkatan 2020. Jangan sampai absen ya! Akan ada games dan doorprize menarik 🎁',
        organizerId: 'user_5',
        organizerName: 'Dewi Kusuma',
        location: 'Aula Barat Campus Center',
        latitude: -6.8880,
        longitude: 107.6120,
        dateTime: now.add(const Duration(days: 14, hours: 18)),
        maxParticipants: 200,
        currentParticipants: 87,
        participantIds: ['user_5', 'user_14'],
        isJoined: false,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];

    for (final event in samples) {
      final list = await getAll();
      list.insert(0, event);
      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    }
  }
}