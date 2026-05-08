import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';

abstract class EventRemoteDataSource {
  Future<List<EventModel>> getAllEvents();
  Future<List<EventModel>> getUpcomingEvents();
  Future<EventModel?> getEventById(String id);
  Future<EventModel> createEvent(EventModel event);
  Future<EventModel> updateEvent(EventModel event);
  Future<void> deleteEvent(String id);
  Future<void> joinEvent(String eventId, String userId);
  Future<void> leaveEvent(String eventId, String userId);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final SupabaseClient supabase;

  EventRemoteDataSourceImpl({required this.supabase});

  // ✅ GUNAKAN VIEW, BUKAN TABEL BASE
  static const _eventsQuery = '''
    *,
    profiles:creator_id (
      name,
      avatar_url
    )
  ''';

  @override
  Future<List<EventModel>> getAllEvents() async {
    // ✅ Query dari VIEW events_with_stats
    final response = await supabase
        .from('events_with_stats') // ← GANTI DI SINI
        .select(_eventsQuery)
        .order('event_date', ascending: true);

    return (response as List).map((json) => EventModel.fromJson(json)).toList();
  }

  @override
  Future<List<EventModel>> getUpcomingEvents() async {
    final now = DateTime.now().toIso8601String();

    // ✅ Query dari VIEW events_with_stats
    final response = await supabase
        .from('events_with_stats') // ← GANTI DI SINI
        .select(_eventsQuery)
        .gte('event_date', now)
        .order('event_date', ascending: true);

    return (response as List).map((json) => EventModel.fromJson(json)).toList();
  }

  @override
  Future<EventModel?> getEventById(String id) async {
    // ✅ Query dari VIEW events_with_stats
    final response = await supabase
        .from('events_with_stats') // ← GANTI DI SINI
        .select(_eventsQuery)
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return EventModel.fromJson(response);
  }

  @override
  Future<EventModel> createEvent(EventModel event) async {
    // ✅ Insert tetap ke tabel base events
    final response = await supabase
        .from('events')
        .insert(event.toInsertJson())
        .select()
        .single();

    return (await getEventById(response['id'] as String))!;
  }

  @override
  Future<EventModel> updateEvent(EventModel event) async {
    // ✅ Update tetap ke tabel base events
    await supabase
        .from('events')
        .update(event.toUpdateJson())
        .eq('id', event.id);

    return (await getEventById(event.id))!;
  }

  @override
  Future<void> deleteEvent(String id) async {
    await supabase.from('events').delete().eq('id', id);
  }

  @override
  Future<void> joinEvent(String eventId, String userId) async {
    // Check if already joined
    final existing = await supabase
        .from('event_participants')
        .select('id')
        .eq('event_id', eventId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) return;

    // Check capacity
    final event = await getEventById(eventId);
    if (event != null && event.isFull) {
      throw Exception('Event is already full');
    }

    await supabase.from('event_participants').insert({
      'event_id': eventId,
      'user_id': userId,
    });
  }

  @override
  Future<void> leaveEvent(String eventId, String userId) async {
    await supabase
        .from('event_participants')
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', userId);
  }
}
