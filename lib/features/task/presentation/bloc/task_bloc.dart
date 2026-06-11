import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  final String userId;

  LoadTasks({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadTasksByDate extends TaskEvent {
  final DateTime date;
  final String userId;

  LoadTasksByDate({required this.date, required this.userId});

  @override
  List<Object?> get props => [date, userId];
}

class AddTask extends TaskEvent {
  final TaskEntity task;
  final String userId;

  AddTask({required this.task, required this.userId});

  @override
  List<Object?> get props => [task, userId];
}

class UpdateTask extends TaskEvent {
  final TaskEntity task;
  final String userId;

  UpdateTask({required this.task, required this.userId});

  @override
  List<Object?> get props => [task, userId];
}

class DeleteTask extends TaskEvent {
  final int id;
  final String userId;

  DeleteTask({required this.id, required this.userId});

  @override
  List<Object?> get props => [id, userId];
}

class ToggleTaskCompletion extends TaskEvent {
  final int id;
  final String userId;

  ToggleTaskCompletion({required this.id, required this.userId});

  @override
  List<Object?> get props => [id, userId];
}

class ToggleTaskPin extends TaskEvent {
  final int id;
  final String userId;

  ToggleTaskPin({required this.id, required this.userId});

  @override
  List<Object?> get props => [id, userId];
}

abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;

  TaskLoaded({required this.tasks});

  @override
  List<Object?> get props => [tasks];
}

class TaskError extends TaskState {
  final String message;

  TaskError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TaskOperationSuccess extends TaskState {
  final String message;

  TaskOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  String? _lastUserId;
  DateTime? _lastDate;

  TaskBloc({required this.repository}) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<LoadTasksByDate>(_onLoadTasksByDate);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<ToggleTaskPin>(_onToggleTaskPin);

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final isOnline = results.any(
        (result) => result != ConnectivityResult.none,
      );
      if (isOnline && _lastUserId != null && !isClosed) {
        final date = _lastDate;
        if (date != null) {
          add(LoadTasksByDate(date: date, userId: _lastUserId!));
        } else {
          add(LoadTasks(userId: _lastUserId!));
        }
      }
    });
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    _lastUserId = event.userId;
    _lastDate = null;
    emit(TaskLoading());
    try {
      final tasks = await repository.getTasksByUser(event.userId);
      emit(TaskLoaded(tasks: tasks));
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> _onLoadTasksByDate(
    LoadTasksByDate event,
    Emitter<TaskState> emit,
  ) async {
    _lastUserId = event.userId;
    _lastDate = event.date;
    emit(TaskLoading());
    try {
      final tasks = await repository.getTasksByUser(event.userId);
      final selectedDate = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      final filteredTasks = tasks.where((task) {
        final deadlineDate = DateTime(
          task.deadline.year,
          task.deadline.month,
          task.deadline.day,
        );
        return deadlineDate == selectedDate;
      }).toList();

      emit(TaskLoaded(tasks: filteredTasks));
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await repository.addTask(event.task);
      emit(TaskOperationSuccess(message: 'Task berhasil ditambahkan'));
      add(LoadTasks(userId: event.userId));
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await repository.updateTask(event.task);
      emit(TaskOperationSuccess(message: 'Task berhasil diperbarui'));
      add(LoadTasks(userId: event.userId));
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await repository.deleteTask(event.id, event.userId);
      emit(TaskOperationSuccess(message: 'Task berhasil dihapus'));
      add(LoadTasks(userId: event.userId));
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> _onToggleTaskCompletion(
    ToggleTaskCompletion event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await repository.toggleTaskCompletion(event.id, event.userId);
      _reloadLastTasks(event.userId);
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> _onToggleTaskPin(
    ToggleTaskPin event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await repository.toggleTaskPin(event.id, event.userId);
      _reloadLastTasks(event.userId);
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _connectivitySubscription?.cancel();
    return super.close();
  }

  void _reloadLastTasks(String userId) {
    final date = _lastDate;
    if (date == null) {
      add(LoadTasks(userId: userId));
    } else {
      add(LoadTasksByDate(date: date, userId: userId));
    }
  }
}
