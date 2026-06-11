import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/datasources/event_location_service.dart';
import '../../data/models/event_route_result.dart';

abstract class EventRouteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadEventRoute extends EventRouteEvent {
  final LatLng destination;

  LoadEventRoute({required this.destination});

  @override
  List<Object?> get props => [destination];
}

abstract class EventRouteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EventRouteInitial extends EventRouteState {}

class EventRouteLoading extends EventRouteState {}

class EventRouteLoaded extends EventRouteState {
  final EventRouteResult route;

  EventRouteLoaded({required this.route});

  @override
  List<Object?> get props => [route];
}

class EventRoutePermissionDenied extends EventRouteState {
  final String message;

  EventRoutePermissionDenied({required this.message});

  @override
  List<Object?> get props => [message];
}

class EventRouteError extends EventRouteState {
  final String message;

  EventRouteError({required this.message});

  @override
  List<Object?> get props => [message];
}

class EventRouteBloc extends Bloc<EventRouteEvent, EventRouteState> {
  final EventLocationService locationService;

  EventRouteBloc({required this.locationService}) : super(EventRouteInitial()) {
    on<LoadEventRoute>(_onLoadRoute);
  }

  Future<void> _onLoadRoute(
    LoadEventRoute event,
    Emitter<EventRouteState> emit,
  ) async {
    emit(EventRouteLoading());
    try {
      final position = await locationService.getCurrentPosition();
      final route = await locationService.fetchRoute(
        origin: LatLng(position.latitude, position.longitude),
        destination: event.destination,
      );
      emit(EventRouteLoaded(route: route));
    } on LocationPermissionDeniedException {
      emit(
        EventRoutePermissionDenied(
          message: 'Izin lokasi diperlukan untuk menampilkan rute.',
        ),
      );
    } on LocationPermissionDeniedForeverException {
      emit(
        EventRoutePermissionDenied(
          message:
              'Izin lokasi ditolak permanen. Aktifkan izin lokasi dari pengaturan aplikasi.',
        ),
      );
    } catch (e) {
      emit(EventRouteError(message: _cleanError(e)));
    }
  }

  String _cleanError(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ') ? message.substring(11) : message;
  }
}
