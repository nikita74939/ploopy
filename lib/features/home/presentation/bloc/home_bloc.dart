import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../schedule/domain/entities/schedule_entity.dart';
import '../../../task/domain/entities/task_entity.dart';
import '../../domain/repositories/home_repository.dart';

// Events
abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {
  final String userId;

  LoadHomeData({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class RefreshHomeData extends HomeEvent {
  final String userId;

  RefreshHomeData({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ToggleHomeTaskCompletion extends HomeEvent {
  final int taskId;
  final String userId;

  ToggleHomeTaskCompletion({required this.taskId, required this.userId});

  @override
  List<Object?> get props => [taskId, userId];
}

// States
abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ScheduleEntity> todaySchedules;
  final List<TaskEntity> tasks;
  final ScheduleEntity? nextSchedule;
  final TaskEntity? nearestTask;
  final int todayStudyMinutes;
  final Map<int, int> weeklyStudyMinutes;

  HomeLoaded({
    required this.todaySchedules,
    required this.tasks,
    this.nextSchedule,
    this.nearestTask,
    required this.todayStudyMinutes,
    required this.weeklyStudyMinutes,
  });

  @override
  List<Object?> get props => [
    todaySchedules,
    tasks,
    nextSchedule,
    nearestTask,
    todayStudyMinutes,
    weeklyStudyMinutes,
  ];
}

class HomeError extends HomeState {
  final String message;

  HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;
  String? _loadingUserId;
  String? _loadedUserId;

  HomeBloc({required this.repository}) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<ToggleHomeTaskCompletion>(_onToggleHomeTaskCompletion);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    if (_loadingUserId == event.userId) return;
    if (state is HomeLoaded && _loadedUserId == event.userId) return;
    _loadingUserId = event.userId;
    emit(HomeLoading());
    try {
      emit(await _loadHomeData(event.userId));
      _loadedUserId = event.userId;
    } catch (e) {
      emit(HomeError(message: e.toString()));
    } finally {
      _loadingUserId = null;
    }
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    if (_loadingUserId == event.userId) return;
    _loadingUserId = event.userId;
    try {
      emit(await _loadHomeData(event.userId));
      _loadedUserId = event.userId;
    } catch (e) {
      emit(HomeError(message: e.toString()));
    } finally {
      _loadingUserId = null;
    }
  }

  Future<HomeLoaded> _loadHomeData(String userId) async {
    final results = await Future.wait<Object?>([
      repository.getTodaySchedules(userId),
      repository.getTasksOrderedByDeadline(userId),
      repository.getNextSchedule(userId),
      repository.getNearestTask(userId),
      repository.getTodayStudyMinutes(userId),
      repository.getCurrentWeekStudyMinutes(userId),
    ]);

    return HomeLoaded(
      todaySchedules: results[0] as List<ScheduleEntity>,
      tasks: results[1] as List<TaskEntity>,
      nextSchedule: results[2] as ScheduleEntity?,
      nearestTask: results[3] as TaskEntity?,
      todayStudyMinutes: results[4] as int,
      weeklyStudyMinutes: results[5] as Map<int, int>,
    );
  }

  Future<void> _onToggleHomeTaskCompletion(
    ToggleHomeTaskCompletion event,
    Emitter<HomeState> emit,
  ) async {
    final previousState = state;
    if (previousState is HomeLoaded) {
      final updatedTasks = previousState.tasks.map((task) {
        if (task.id != event.taskId) return task;
        return task.copyWith(isCompleted: !task.isCompleted);
      }).toList();

      emit(
        HomeLoaded(
          todaySchedules: previousState.todaySchedules,
          tasks: updatedTasks,
          nextSchedule: previousState.nextSchedule,
          nearestTask: previousState.nearestTask?.id == event.taskId
              ? null
              : previousState.nearestTask,
          todayStudyMinutes: previousState.todayStudyMinutes,
          weeklyStudyMinutes: previousState.weeklyStudyMinutes,
        ),
      );
    }

    try {
      await repository.toggleTaskCompletion(event.taskId, event.userId);
      emit(await _loadHomeData(event.userId));
      _loadedUserId = event.userId;
    } catch (e) {
      if (previousState is HomeLoaded) emit(previousState);
      emit(HomeError(message: e.toString()));
    }
  }
}
