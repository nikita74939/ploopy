// lib/features/study_desk/domain/study_session.dart
enum StudyState { idle, focusing, paused }

class StudySession {
  final DateTime sessionStart;
  final Duration totalDuration;
  final Duration sessionDuration;
  final StudyState state;

  const StudySession({
    required this.sessionStart,
    required this.totalDuration,
    required this.sessionDuration,
    required this.state,
  });

  StudySession copyWith({
    DateTime? sessionStart,
    Duration? totalDuration,
    Duration? sessionDuration,
    StudyState? state,
  }) {
    return StudySession(
      sessionStart: sessionStart ?? this.sessionStart,
      totalDuration: totalDuration ?? this.totalDuration,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      state: state ?? this.state,
    );
  }

  factory StudySession.initial() {
    return StudySession(
      sessionStart: DateTime.now(),
      totalDuration: Duration.zero,
      sessionDuration: Duration.zero,
      state: StudyState.idle,
    );
  }
}