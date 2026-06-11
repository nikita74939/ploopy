import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/study_repository.dart';
import '../../domain/models/study_session_model.dart';

enum StudyTimerMode { idle, focus, shortBreak, longBreak }

extension StudyTimerModeLabel on StudyTimerMode {
  String get label {
    switch (this) {
      case StudyTimerMode.focus:
        return 'Focus Mode';
      case StudyTimerMode.shortBreak:
        return 'Short Break';
      case StudyTimerMode.longBreak:
        return 'Long Break';
      case StudyTimerMode.idle:
        return 'Focus Mode';
    }
  }
}

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

class SwitchStudyTimerMode extends StudyEvent {
  final StudyTimerMode mode;

  SwitchStudyTimerMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

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
  final int durationSeconds;
  final StudyTimerMode mode;
  final int todayStudyMinutes;
  final int streak;

  StudyInProgress({
    required this.sessionId,
    required this.elapsedSeconds,
    required this.durationSeconds,
    required this.mode,
    required this.todayStudyMinutes,
    required this.streak,
  });

  @override
  List<Object?> get props => [
    sessionId,
    elapsedSeconds,
    durationSeconds,
    mode,
    todayStudyMinutes,
    streak,
  ];
}

class StudyPaused extends StudyState {
  final int sessionId;
  final int elapsedSeconds;
  final int durationSeconds;
  final StudyTimerMode mode;
  final int todayStudyMinutes;
  final int streak;

  StudyPaused({
    required this.sessionId,
    required this.elapsedSeconds,
    required this.durationSeconds,
    required this.mode,
    required this.todayStudyMinutes,
    required this.streak,
  });

  @override
  List<Object?> get props => [
    sessionId,
    elapsedSeconds,
    durationSeconds,
    mode,
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
  int _focusElapsedSeconds = 0;
  int _durationSeconds = _focusDurationSeconds;
  int _todayMinutes = 0;
  int _streak = 0;
  StudyTimerMode _timerMode = StudyTimerMode.idle;
  String? _currentUserId;
  String? _loadingUserId;
  static const int _focusDurationSeconds = 25 * 60;
  static const int _shortBreakDurationSeconds = 5 * 60;
  static const int _longBreakDurationSeconds = 15 * 60;

  StudyBloc({required this.repository}) : super(StudyInitial()) {
    on<LoadStudyData>(_onLoadStudyData);
    on<StartStudySession>(_onStartStudySession);
    on<PauseStudySession>(_onPauseStudySession);
    on<ResumeStudySession>(_onResumeStudySession);
    on<EndStudySession>(_onEndStudySession);
    on<SwitchStudyTimerMode>(_onSwitchStudyTimerMode);
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
    if (_loadingUserId == event.userId) return;
    if (_currentUserId == event.userId && state is StudyIdle) return;
    _loadingUserId = event.userId;
    emit(StudyLoading());
    try {
      _currentUserId = event.userId;
      final results = await Future.wait<Object>([
        repository.getTodayStudyMinutes(event.userId),
        repository.getStreak(event.userId),
        repository.getSessionsByDate(event.userId, DateTime.now()),
      ]);
      _todayMinutes = results[0] as int;
      _streak = results[1] as int;
      emit(
        StudyIdle(
          todayStudyMinutes: _todayMinutes,
          streak: _streak,
          sessions: results[2] as List<StudySessionModel>,
        ),
      );
    } catch (e) {
      emit(StudyError(message: e.toString()));
    } finally {
      _loadingUserId = null;
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
      _focusElapsedSeconds = 0;
      _timerMode = StudyTimerMode.focus;
      _durationSeconds = _durationForMode(_timerMode);
      _startTimer(fromSeconds: _elapsedSeconds);
      emit(
        StudyInProgress(
          sessionId: _currentSessionId,
          elapsedSeconds: _elapsedSeconds,
          durationSeconds: _durationSeconds,
          mode: _timerMode,
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
        durationSeconds: _durationSeconds,
        mode: _timerMode,
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
        durationSeconds: _durationSeconds,
        mode: _timerMode,
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
      final durationMinutes = _focusElapsedSeconds ~/ 60;
      await repository.endSession(_currentSessionId, durationMinutes);
      _elapsedSeconds = 0;
      _focusElapsedSeconds = 0;
      _durationSeconds = _focusDurationSeconds;
      _timerMode = StudyTimerMode.idle;

      add(LoadStudyData(userId: userId));
    } catch (e) {
      emit(StudyError(message: e.toString()));
    }
  }

  void _onSwitchStudyTimerMode(
    SwitchStudyTimerMode event,
    Emitter<StudyState> emit,
  ) {
    if (state is! StudyInProgress && state is! StudyPaused) return;
    if (event.mode == StudyTimerMode.idle) return;

    _timerMode = event.mode;
    _durationSeconds = _durationForMode(event.mode);
    _elapsedSeconds = 0;
    _startTimer(fromSeconds: _elapsedSeconds);
    emit(
      StudyInProgress(
        sessionId: _currentSessionId,
        elapsedSeconds: _elapsedSeconds,
        durationSeconds: _durationSeconds,
        mode: _timerMode,
        todayStudyMinutes: _todayMinutes,
        streak: _streak,
      ),
    );
  }

  void _onTimerTick(_TimerTick event, Emitter<StudyState> emit) {
    _elapsedSeconds = event.seconds;
    if (_timerMode == StudyTimerMode.focus) {
      _focusElapsedSeconds = _elapsedSeconds;
    }
    if (_elapsedSeconds >= _durationSeconds) {
      _elapsedSeconds = _durationSeconds;
      _timer?.cancel();
    }
    emit(
      StudyInProgress(
        sessionId: _currentSessionId,
        elapsedSeconds: _elapsedSeconds,
        durationSeconds: _durationSeconds,
        mode: _timerMode,
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

  int _durationForMode(StudyTimerMode mode) {
    switch (mode) {
      case StudyTimerMode.shortBreak:
        return _shortBreakDurationSeconds;
      case StudyTimerMode.longBreak:
        return _longBreakDurationSeconds;
      case StudyTimerMode.focus:
      case StudyTimerMode.idle:
        return _focusDurationSeconds;
    }
  }
}
