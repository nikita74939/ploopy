class StudySessionEntity {
  final int id;
  final String userId;
  final DateTime sessionDate;
  final int totalDurationSec;
  final int focusDurationSec;
  final DateTime startedAt;
  final DateTime? endedAt;

  const StudySessionEntity({
    required this.id,
    required this.userId,
    required this.sessionDate,
    required this.totalDurationSec,
    required this.focusDurationSec,
    required this.startedAt,
    this.endedAt,
  });
}
