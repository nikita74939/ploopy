import '../entities/event_entity.dart';

abstract class EventRepository {
  Future<List<EventEntity>> getAllEvents();
  Future<List<EventEntity>> getUpcomingEvents();
  Future<EventEntity?> getEventById(String id);
  Future<EventEntity> createEvent(EventEntity event);
  Future<EventEntity> updateEvent(EventEntity event);
  Future<void> deleteEvent(String id);
  Future<void> joinEvent(String eventId, String userId);
  Future<void> leaveEvent(String eventId, String userId);
}
