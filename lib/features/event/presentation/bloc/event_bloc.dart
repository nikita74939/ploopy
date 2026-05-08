import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/event_repository.dart';
import '../../data/models/event_model.dart';

// ─────────────────────────────────────────
// Events
// ─────────────────────────────────────────

abstract class EventEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadEvents extends EventEvent {}

class LoadUpcomingEvents extends EventEvent {}

class CreateEvent extends EventEvent {
  final EventModel event;

  CreateEvent({required this.event});

  @override
  List<Object?> get props => [event];
}

class UpdateEvent extends EventEvent {
  final EventModel event;

  UpdateEvent({required this.event});

  @override
  List<Object?> get props => [event];
}

class DeleteEvent extends EventEvent {
  final String id;

  DeleteEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class JoinEvent extends EventEvent {
  final String eventId;
  final String userId;

  JoinEvent({required this.eventId, required this.userId});

  @override
  List<Object?> get props => [eventId, userId];
}

class LeaveEvent extends EventEvent {
  final String eventId;
  final String userId;

  LeaveEvent({required this.eventId, required this.userId});

  @override
  List<Object?> get props => [eventId, userId];
}

// ─────────────────────────────────────────
// States
// ─────────────────────────────────────────

abstract class EventState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventsLoaded extends EventState {
  final List<EventModel> events;

  EventsLoaded({required this.events});

  @override
  List<Object?> get props => [events];
}

class EventOperationSuccess extends EventState {
  final String message;

  EventOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class EventError extends EventState {
  final String message;

  EventError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────
// BLoC
// ─────────────────────────────────────────

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository repository;

  EventBloc({required this.repository}) : super(EventInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<LoadUpcomingEvents>(_onLoadUpcomingEvents);
    on<CreateEvent>(_onCreateEvent);
    on<UpdateEvent>(_onUpdateEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<JoinEvent>(_onJoinEvent);
    on<LeaveEvent>(_onLeaveEvent);
  }

  Future<void> _onLoadEvents(
    LoadEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      final events = await repository.getAllEvents();
      emit(EventsLoaded(events: events));
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onLoadUpcomingEvents(
    LoadUpcomingEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      final events = await repository.getUpcomingEvents();
      emit(EventsLoaded(events: events));
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onCreateEvent(
    CreateEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      await repository.createEvent(event.event);
      emit(EventOperationSuccess(message: 'Event created successfully'));
      add(LoadEvents());
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onUpdateEvent(
    UpdateEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      await repository.updateEvent(event.event);
      emit(EventOperationSuccess(message: 'Event updated successfully'));
      add(LoadEvents());
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onDeleteEvent(
    DeleteEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      await repository.deleteEvent(event.id);
      emit(EventOperationSuccess(message: 'Event deleted'));
      add(LoadEvents());
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onJoinEvent(
    JoinEvent event,
    Emitter<EventState> emit,
  ) async {
    try {
      await repository.joinEvent(event.eventId, event.userId);
      add(LoadEvents());
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onLeaveEvent(
    LeaveEvent event,
    Emitter<EventState> emit,
  ) async {
    try {
      await repository.leaveEvent(event.eventId, event.userId);
      add(LoadEvents());
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }
}