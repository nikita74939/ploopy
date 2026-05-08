import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_data_source.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<EventModel>> getAllEvents() =>
      remoteDataSource.getAllEvents();

  @override
  Future<List<EventModel>> getUpcomingEvents() =>
      remoteDataSource.getUpcomingEvents();

  @override
  Future<EventModel?> getEventById(String id) =>
      remoteDataSource.getEventById(id);

  @override
  Future<EventModel> createEvent(EventModel event) =>
      remoteDataSource.createEvent(event);

  @override
  Future<EventModel> updateEvent(EventModel event) =>
      remoteDataSource.updateEvent(event);

  @override
  Future<void> deleteEvent(String id) =>
      remoteDataSource.deleteEvent(id);

  @override
  Future<void> joinEvent(String eventId, String userId) =>
      remoteDataSource.joinEvent(eventId, userId);

  @override
  Future<void> leaveEvent(String eventId, String userId) =>
      remoteDataSource.leaveEvent(eventId, userId);
}