// Aggregated view for a single calendar day
class CalendarDayEntity {
  final DateTime date;
  final int studyMinutes;   // used for heatmap color
  final int tasksCompleted; // used for dot indicator
  final List<String> scheduleIds;
  final List<String> completedTaskIds;

  const CalendarDayEntity({
    required this.date,
    required this.studyMinutes,
    required this.tasksCompleted,
    required this.scheduleIds,
    required this.completedTaskIds,
  });
}
