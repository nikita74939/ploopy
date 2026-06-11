import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/study_repository.dart';
import '../../domain/models/study_session_model.dart';

// Events
abstract class StudyEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStudyData extends StudyEvent {
  final String userId;

  LoadStudyData({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class StartStudySession extends StudyEvent {
  final String userId;

  StartStudySession({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class PauseStudySession extends StudyEvent {}

class ResumeStudySession extends StudyEvent {}

class EndStudySession extends StudyEvent {}

class _TimerTick extends StudyEvent {
  final int seconds;

  _TimerTick({required this.seconds});

  @override
  List<Object?> get props => [seconds];
}

// States
abstract class StudyState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StudyInitial extends StudyState {}

class StudyLoading extends StudyState {}

class StudyIdle extends StudyState {
  final int todayStudyMinutes;
  final int streak;
  final List<StudySessionModel> sessions;

  StudyIdle({
    required this.todayStudyMinutes,
    required this.streak,
    required this.sessions,
  });

  @override
  List<Object?> get props => [todayStudyMinutes, streak, sessions];
}

class StudyInProgress extends StudyState {
  final int sessionId;
  final int elapsedSeconds;
  final int todayStudyMinutes;
  final int streak;

  StudyInProgress({
    required this.sessionId,
    required this.elapsedSeconds,
    required this.todayStudyMinutes,
    required this.streak,
  });

  @override
  List<Object?> get props => [
    sessionId,
    elapsedSeconds,
    todayStudyMinutes,
    streak,
  ];
}

class StudyPaused extends StudyState {
  final int sessionId;
  final int elapsedSeconds;
  final int todayStudyMinutes;
  final int streak;

  StudyPaused({
    required this.sessionId,
    required this.elapsedSeconds,
    required this.todayStudyMinutes,
    required this.streak,
  });

  @override
  List<Object?> get props => [
    sessionId,
    elapsedSeconds,
    todayStudyMinutes,
    streak,
  ];
}

class StudyError extends StudyState {
  final String message;

  StudyError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class StudyBloc extends Bloc<StudyEvent, StudyState> {
  final StudyRepository repository;
  Timer? _timer;
  int _currentSessionId = 0;
  int _elapsedSeconds = 0;
  int _todayMinutes = 0;
  int _streak = 0;
  String? _currentUserId;

  StudyBloc({required this.repository}) : super(StudyInitial()) {
    on<LoadStudyData>(_onLoadStudyData);
    on<StartStudySession>(_onStartStudySession);
    on<PauseStudySession>(_onPauseStudySession);
    on<ResumeStudySession>(_onResumeStudySession);
    on<EndStudySession>(_onEndStudySession);
    on<_TimerTick>(_onTimerTick);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> _onLoadStudyData(
    LoadStudyData event,
    Emitter<StudyState> emit,
  ) async {
    emit(StudyLoading());
    try {
      _currentUserId = event.userId;
      _todayMinutes = await repository.getTodayStudyMinutes(event.userId);
      _streak = await repository.getStreak(event.userId);
      final sessions = await repository.getSessionsByDate(
        event.userId,
        DateTime.now(),
      );
      emit(
        StudyIdle(
          todayStudyMinutes: _todayMinutes,
          streak: _streak,
          sessions: sessions,
        ),
      );
    } catch (e) {
      emit(StudyError(message: e.toString()));
    }
  }

  Future<void> _onStartStudySession(
    StartStudySession event,
    Emitter<StudyState> emit,
  ) async {
    try {
      _currentUserId = event.userId;
      _currentSessionId = await repository.startSession(event.userId);
      _elapsedSeconds = 0;
      _startTimer(fromSeconds: _elapsedSeconds);
      emit(
        StudyInProgress(
          sessionId: _currentSessionId,
          elapsedSeconds: _elapsedSeconds,
          todayStudyMinutes: _todayMinutes,
          streak: _streak,
        ),
      );
    } catch (e) {
      emit(StudyError(message: e.toString()));
    }
  }

  void _onPauseStudySession(PauseStudySession event, Emitter<StudyState> emit) {
    _timer?.cancel();
    emit(
      StudyPaused(
        sessionId: _currentSessionId,
        elapsedSeconds: _elapsedSeconds,
        todayStudyMinutes: _todayMinutes,
        streak: _streak,
      ),
    );
  }

  void _onResumeStudySession(
    ResumeStudySession event,
    Emitter<StudyState> emit,
  ) {
    _startTimer(fromSeconds: _elapsedSeconds);
    emit(
      StudyInProgress(
        sessionId: _currentSessionId,
        elapsedSeconds: _elapsedSeconds,
        todayStudyMinutes: _todayMinutes,
        streak: _streak,
      ),
    );
  }

  Future<void> _onEndStudySession(
    EndStudySession event,
    Emitter<StudyState> emit,
  ) async {
    _timer?.cancel();
    try {
      final userId = _currentUserId;
      if (userId == null) return;
      final durationMinutes = _elapsedSeconds ~/ 60;
      await repository.endSession(_currentSessionId, durationMinutes);

      add(LoadStudyData(userId: userId));
    } catch (e) {
      emit(StudyError(message: e.toString()));
    }
  }

  void _onTimerTick(_TimerTick event, Emitter<StudyState> emit) {
    _elapsedSeconds = event.seconds;
    emit(
      StudyInProgress(
        sessionId: _currentSessionId,
        elapsedSeconds: _elapsedSeconds,
        todayStudyMinutes: _todayMinutes,
        streak: _streak,
      ),
    );
  }

  void _startTimer({required int fromSeconds}) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(_TimerTick(seconds: fromSeconds + timer.tick));
    });
  }
}
