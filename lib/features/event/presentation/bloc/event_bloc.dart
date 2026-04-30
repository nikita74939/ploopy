// event/presentation/bloc/event_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/event_model.dart';
import '../../../../core/constants/event_dummy_data.dart';

// Events
abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class LoadEvents extends EventEvent {}

class FilterEvents extends EventEvent {
  final int filterIndex;

  const FilterEvents(this.filterIndex);

  @override
  List<Object?> get props => [filterIndex];
}

class JoinEvent extends EventEvent {
  final String eventId;

  const JoinEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class LeaveEvent extends EventEvent {
  final String eventId;

  const LeaveEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

// States
abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventLoaded extends EventState {
  final List<Event> events;
  final List<Event> filteredEvents;
  final int currentFilter;

  const EventLoaded({
    required this.events,
    required this.filteredEvents,
    this.currentFilter = 0,
  });

  @override
  List<Object?> get props => [events, filteredEvents, currentFilter];

  EventLoaded copyWith({
    List<Event>? events,
    List<Event>? filteredEvents,
    int? currentFilter,
  }) {
    return EventLoaded(
      events: events ?? this.events,
      filteredEvents: filteredEvents ?? this.filteredEvents,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class EventError extends EventState {
  final String message;

  const EventError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class EventBloc extends Bloc<EventEvent, EventState> {
  EventBloc() : super(EventInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<FilterEvents>(_onFilterEvents);
    on<JoinEvent>(_onJoinEvent);
    on<LeaveEvent>(_onLeaveEvent);
  }

  void _onLoadEvents(LoadEvents event, Emitter<EventState> emit) {
    emit(EventLoading());

    try {
      final allEvents = EventDummyData.events; // Store reference first

      final events =
          allEvents
              .map(
                (e) => Event(
                  id: e.hashCode.toString(),
                  title: e['title'] as String,
                  description: 'Deskripsi event untuk ${e['title']}',
                  organizerId: '1',
                  organizerName: 'Mahasiswa',
                  location: e['location'] as String?,
                  latitude: e['latitude'] as double?,
                  longitude: e['longitude'] as double?,
                  dateTime: DateTime.now().add(
                    Duration(days: allEvents.length),
                  ), // ✅ Use allEvents
                  maxParticipants: e['maxParticipants'] as int,
                  currentParticipants: e['participants'] as int,
                  imageUrl: e['imageUrl'] as String?,
                  isJoined: e['joined'] as bool,
                  createdAt: DateTime.now(),
                ),
              )
              .toList();

      emit(EventLoaded(events: events, filteredEvents: events));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  void _onFilterEvents(FilterEvents event, Emitter<EventState> emit) {
    if (state is EventLoaded) {
      final currentState = state as EventLoaded;
      // final filters = ['Semua', 'Terdekat', 'Joined', 'Terbaru'];

      List<Event> filtered;
      switch (event.filterIndex) {
        case 1: // Terdekat
          filtered = currentState.events.where((e) => e.hasLocation).toList();
          break;
        case 2: // Joined
          filtered = currentState.events.where((e) => e.isJoined).toList();
          break;
        case 3: // Terbaru
          filtered =
              currentState.events.toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        default: // Semua
          filtered = currentState.events;
      }

      emit(
        currentState.copyWith(
          filteredEvents: filtered,
          currentFilter: event.filterIndex,
        ),
      );
    }
  }

  // event/presentation/bloc/event_bloc.dart (lanjutan)

  void _onJoinEvent(JoinEvent event, Emitter<EventState> emit) {
    if (state is EventLoaded) {
      final currentState = state as EventLoaded;

      final updatedEvents =
          currentState.events.map((e) {
            if (e.id == event.eventId) {
              return e.copyWith(
                isJoined: true,
                currentParticipants: e.currentParticipants + 1,
                participantIds: [...e.participantIds, 'current_user_id'],
              );
            }
            return e;
          }).toList();

      emit(
        currentState.copyWith(
          events: updatedEvents,
          filteredEvents: _applyFilter(
            updatedEvents,
            currentState.currentFilter,
          ),
        ),
      );
    }
  }

  void _onLeaveEvent(LeaveEvent event, Emitter<EventState> emit) {
    if (state is EventLoaded) {
      final currentState = state as EventLoaded;

      final updatedEvents =
          currentState.events.map((e) {
            if (e.id == event.eventId) {
              return e.copyWith(
                isJoined: false,
                currentParticipants: e.currentParticipants - 1,
                participantIds:
                    e.participantIds
                        .where((id) => id != 'current_user_id')
                        .toList(),
              );
            }
            return e;
          }).toList();

      emit(
        currentState.copyWith(
          events: updatedEvents,
          filteredEvents: _applyFilter(
            updatedEvents,
            currentState.currentFilter,
          ),
        ),
      );
    }
  }

  List<Event> _applyFilter(List<Event> events, int filterIndex) {
    switch (filterIndex) {
      case 1:
        return events.where((e) => e.hasLocation).toList();
      case 2:
        return events.where((e) => e.isJoined).toList();
      case 3:
        return events.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      default:
        return events;
    }
  }
}
