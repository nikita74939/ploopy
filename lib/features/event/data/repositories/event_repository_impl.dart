import '../../domain/repositories/event_repository.dart';
import '../../domain/entities/event_entity.dart';
import '../datasources/event_remote_data_source.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<EventEntity>> getAllEvents() async {
    final events = await remoteDataSource.getAllEvents();
    return events.map((event) => event.toEntity()).toList();
  }

  @override
  Future<List<EventEntity>> getUpcomingEvents() async {
    final events = await remoteDataSource.getUpcomingEvents();
    return events.map((event) => event.toEntity()).toList();
  }

  @override
  Future<EventEntity?> getEventById(String id) async {
    final event = await remoteDataSource.getEventById(id);
    return event?.toEntity();
  }

  @override
  Future<EventEntity> createEvent(EventEntity event) async {
    final created = await remoteDataSource.createEvent(
      EventModel.fromEntity(event),
    );
    return created.toEntity();
  }

  @override
  Future<EventEntity> updateEvent(EventEntity event) async {
    final updated = await remoteDataSource.updateEvent(
      EventModel.fromEntity(event),
    );
    return updated.toEntity();
  }

  @override
  Future<void> deleteEvent(String id) => remoteDataSource.deleteEvent(id);

  @override
  Future<void> joinEvent(String eventId, String userId) =>
      remoteDataSource.joinEvent(eventId, userId);

  @override
  Future<void> leaveEvent(String eventId, String userId) =>
      remoteDataSource.leaveEvent(eventId, userId);
}
