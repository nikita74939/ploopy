import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/entities/schedule_entity.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class ScheduleEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSchedules extends ScheduleEvent {
  final String userId;
  LoadSchedules({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadSchedulesByDate extends ScheduleEvent {
  final DateTime date;
  LoadSchedulesByDate({required this.date});

  @override
  List<Object?> get props => [date];
}

class AddSchedule extends ScheduleEvent {
  final ScheduleEntity schedule;
  AddSchedule({required this.schedule});

  @override
  List<Object?> get props => [schedule];
}

class UpdateSchedule extends ScheduleEvent {
  final ScheduleEntity schedule;
  UpdateSchedule({required this.schedule});

  @override
  List<Object?> get props => [schedule];
}

class DeleteSchedule extends ScheduleEvent {
  final int id;
  final String userId;
  DeleteSchedule({required this.id, required this.userId});

  @override
  List<Object?> get props => [id, userId];
}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class ScheduleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<ScheduleEntity> schedules;
  ScheduleLoaded({required this.schedules});

  @override
  List<Object?> get props => [schedules];
}

class ScheduleError extends ScheduleState {
  final String message;
  ScheduleError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ScheduleOperationSuccess extends ScheduleState {
  final String message;
  ScheduleOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleRepository repository;

  ScheduleBloc({required this.repository}) : super(ScheduleInitial()) {
    on<LoadSchedules>(_onLoadSchedules);
    on<LoadSchedulesByDate>(_onLoadSchedulesByDate);
    on<AddSchedule>(_onAddSchedule);
    on<UpdateSchedule>(_onUpdateSchedule);
    on<DeleteSchedule>(_onDeleteSchedule);
  }

  Future<void> _onLoadSchedules(
    LoadSchedules event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());
    try {
      final schedules = await repository.getUpcomingSchedules(event.userId);
      emit(ScheduleLoaded(schedules: schedules));
    } catch (e) {
      emit(ScheduleError(message: e.toString()));
    }
  }

  Future<void> _onLoadSchedulesByDate(
    LoadSchedulesByDate event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());
    try {
      final schedules = await repository.getSchedulesByDate(event.date);
      emit(ScheduleLoaded(schedules: schedules));
    } catch (e) {
      emit(ScheduleError(message: e.toString()));
    }
  }

  Future<void> _onAddSchedule(
    AddSchedule event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());
    try {
      await repository.addSchedule(event.schedule);
      emit(ScheduleOperationSuccess(message: 'Jadwal berhasil ditambahkan'));
      add(LoadSchedules(userId: event.schedule.userId));
    } catch (e) {
      emit(ScheduleError(message: e.toString()));
    }
  }

  Future<void> _onUpdateSchedule(
    UpdateSchedule event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());
    try {
      await repository.updateSchedule(event.schedule);
      emit(ScheduleOperationSuccess(message: 'Jadwal berhasil diperbarui'));
      add(LoadSchedules(userId: event.schedule.userId));
    } catch (e) {
      emit(ScheduleError(message: e.toString()));
    }
  }

  Future<void> _onDeleteSchedule(
    DeleteSchedule event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());
    try {
      await repository.deleteSchedule(event.id);
      emit(ScheduleOperationSuccess(message: 'Jadwal berhasil dihapus'));
      add(LoadSchedules(userId: event.userId));
    } catch (e) {
      emit(ScheduleError(message: e.toString()));
    }
  }
}