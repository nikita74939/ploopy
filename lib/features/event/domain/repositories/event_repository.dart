import '../../data/models/event_model.dart';

abstract class EventRepository {
  Future<List<EventModel>> getAllEvents();
  Future<List<EventModel>> getUpcomingEvents();
  Future<EventModel?> getEventById(String id);
  Future<EventModel> createEvent(EventModel event);
  Future<EventModel> updateEvent(EventModel event);
  Future<void> deleteEvent(String id);
  Future<void> joinEvent(String eventId, String userId);
  Future<void> leaveEvent(String eventId, String userId);
}