import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/task_repository.dart';
import '../../data/models/task_model.dart';

// Events
abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  final String userId; // TAMBAHAN

  LoadTasks({required this.userId}); // TAMBAHAN

  @override
  List<Object?> get props => [userId];
}

class LoadTasksByDate extends TaskEvent {
  final DateTime date;
  final String userId; // TAMBAHAN

  LoadTasksByDate({required this.date, required this.userId}); // TAMBAHAN

  @override
  List<Object?> get props => [date, userId];
}

class AddTask extends TaskEvent {
  final TaskModel task;
  final String userId; // TAMBAHAN

  AddTask({required this.task, required this.userId}); // TAMBAHAN

  @override
  List<Object?> get props => [task, userId];
}

class UpdateTask extends TaskEvent {
  final TaskModel task;
  final String userId;

  UpdateTask({required this.task, required this.userId});

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final int id;
  final String userId;

  DeleteTask({required this.id, required this.userId});

  @override
  List<Object?> get props => [id];
}

class ToggleTaskCompletion extends TaskEvent {
  final int id;
  final String userId;

  ToggleTaskCompletion({required this.id, required this.userId});

  @override
  List<Object?> get props => [id];
}

class ToggleTaskPin extends TaskEvent {
  final int id;
  final String userId;

  ToggleTaskPin({required this.id, required this.userId});

  @override
  List<Object?> get props => [id];
}

// States
abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;

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

// BLoC
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;

  TaskBloc({required this.repository}) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<LoadTasksByDate>(_onLoadTasksByDate);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<ToggleTaskPin>(_onToggleTaskPin);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await repository.getTasksByUser(event.userId); // UBAH
      emit(TaskLoaded(tasks: tasks));
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> _onLoadTasksByDate(
    LoadTasksByDate event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final tasks = await repository.getTasksByUser(
        event.userId,
      ); // UBAH - filter by user and date
      emit(TaskLoaded(tasks: tasks));
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final taskWithUserId = TaskModel.create(
        name: event.task.name,
        subject: event.task.subject,
        deadline: event.task.deadline,
        details: event.task.details,
        color: event.task.color,
        iconName: event.task.iconName,
        isPinned: event.task.isPinned,
        isCompleted: event.task.isCompleted,
        userId: event.userId,
      );
      await repository.addTask(taskWithUserId);
      emit(TaskOperationSuccess(message: 'Task added successfully'));
      add(LoadTasks(userId: event.userId));  // TAMBAHAN
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
  emit(TaskLoading());
  try {
    await repository.updateTask(event.task);
    emit(TaskOperationSuccess(message: 'Task updated successfully'));
    add(LoadTasks(userId: event.userId));  // ✅ Sudah benar
  } catch (e) {
    emit(TaskError(message: e.toString()));
  }
}

Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
  emit(TaskLoading());
  try {
    await repository.deleteTask(event.id, event.userId);
    emit(TaskOperationSuccess(message: 'Task deleted successfully'));
    add(LoadTasks(userId: event.userId));  // ✅ PERBAIKI - tambah userId
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
    add(LoadTasks(userId: event.userId));  // ✅ PERBAIKI - tambah userId
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
    add(LoadTasks(userId: event.userId));  // ✅ PERBAIKI - tambah userId
  } catch (e) {
    emit(TaskError(message: e.toString()));
  }
}
}
