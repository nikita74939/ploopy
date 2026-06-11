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

  HomeBloc({required this.repository}) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final schedules = await repository.getTodaySchedules(event.userId);
      final tasks = await repository.getTasksOrderedByDeadline(event.userId);
      final nextSchedule = await repository.getNextSchedule(event.userId);
      final nearestTask = await repository.getNearestTask(event.userId);
      final studyMinutes = await repository.getTodayStudyMinutes(event.userId);
      final weeklyStudyMinutes = await repository.getCurrentWeekStudyMinutes(
        event.userId,
      );

      emit(
        HomeLoaded(
          todaySchedules: schedules,
          tasks: tasks,
          nextSchedule: nextSchedule,
          nearestTask: nearestTask,
          todayStudyMinutes: studyMinutes,
          weeklyStudyMinutes: weeklyStudyMinutes,
        ),
      );
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final schedules = await repository.getTodaySchedules(event.userId);
      final tasks = await repository.getTasksOrderedByDeadline(event.userId);
      final nextSchedule = await repository.getNextSchedule(event.userId);
      final nearestTask = await repository.getNearestTask(event.userId);
      final studyMinutes = await repository.getTodayStudyMinutes(event.userId);
      final weeklyStudyMinutes = await repository.getCurrentWeekStudyMinutes(
        event.userId,
      );

      emit(
        HomeLoaded(
          todaySchedules: schedules,
          tasks: tasks,
          nextSchedule: nextSchedule,
          nearestTask: nearestTask,
          todayStudyMinutes: studyMinutes,
          weeklyStudyMinutes: weeklyStudyMinutes,
        ),
      );
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
