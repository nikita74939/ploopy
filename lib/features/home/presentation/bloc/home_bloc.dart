import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../task/data/models/task_model.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../schedule/data/models/schedule_model.dart';
// Events
abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {}

class RefreshHomeData extends HomeEvent {}

// States
abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ScheduleModel> todaySchedules;
  final List<TaskModel> tasks;
  final ScheduleModel? nextSchedule;
  final TaskModel? nearestTask;
  final int todayStudyMinutes;

  HomeLoaded({
    required this.todaySchedules,
    required this.tasks,
    this.nextSchedule,
    this.nearestTask,
    required this.todayStudyMinutes,
  });

  @override
  List<Object?> get props => [
        todaySchedules,
        tasks,
        nextSchedule,
        nearestTask,
        todayStudyMinutes,
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
      final schedules = await repository.getTodaySchedules();
      final tasks = await repository.getTasksOrderedByDeadline();
      final nextSchedule = await repository.getNextSchedule();
      final nearestTask = await repository.getNearestTask();
      final studyMinutes = await repository.getTodayStudyMinutes();

      emit(HomeLoaded(
        todaySchedules: schedules,
        tasks: tasks,
        nextSchedule: nextSchedule,
        nearestTask: nearestTask,
        todayStudyMinutes: studyMinutes,
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final schedules = await repository.getTodaySchedules();
      final tasks = await repository.getTasksOrderedByDeadline();
      final nextSchedule = await repository.getNextSchedule();
      final nearestTask = await repository.getNearestTask();
      final studyMinutes = await repository.getTodayStudyMinutes();

      emit(HomeLoaded(
        todaySchedules: schedules,
        tasks: tasks,
        nextSchedule: nextSchedule,
        nearestTask: nearestTask,
        todayStudyMinutes: studyMinutes,
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}