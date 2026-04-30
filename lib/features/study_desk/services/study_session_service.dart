// lib/features/study_desk/services/study_session_service.dart

import 'dart:async';
import '../domain/study_session.dart';

class StudySessionService {
  static final StudySessionService _instance = StudySessionService._internal();
  factory StudySessionService() => _instance;
  StudySessionService._internal();

  StudySession _session = StudySession.initial();
  Timer? _timer;
  // ignore: unused_field
  DateTime? _sessionStartTime;

  final List<void Function(StudySession)> _listeners = [];

  StudySession get currentSession => _session;
  Stream<StudySession> get sessionStream => _createStream();

  Stream<StudySession> _createStream() {
    return Stream.periodic(const Duration(seconds: 1)).map((_) => _session);
  }

  void addListener(void Function(StudySession) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(StudySession) listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_session);
    }
  }

  void startSession() {
    if (_session.state == StudyState.focusing) return;

    final now = DateTime.now();
    _sessionStartTime = now;

    _session = _session.copyWith(
      sessionStart: now,
      sessionDuration: Duration.zero,
      state: StudyState.focusing,
    );

    _startTimer();
    _notifyListeners();
  }

  void pauseSession() {
    if (_session.state != StudyState.focusing) return;

    _timer?.cancel();

    // Akumulasi total duration
    final newTotalDuration = _session.totalDuration + _session.sessionDuration;

    _session = _session.copyWith(
      totalDuration: newTotalDuration,
      sessionDuration: Duration.zero,
      state: StudyState.paused,
    );

    _notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    final startTime = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final elapsed = DateTime.now().difference(startTime);
      _session = _session.copyWith(sessionDuration: elapsed);
      _notifyListeners();
    });
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int get totalStudyHours => _session.totalDuration.inHours;

  void dispose() {
    _timer?.cancel();
    _listeners.clear();
  }
}