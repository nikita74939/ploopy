import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/neo_container.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../study/presentation/bloc/study_bloc.dart';
import '../../../schedule/presentation/bloc/schedule_bloc.dart';
import '../../../schedule/domain/entities/schedule_entity.dart';
import '../../../task/data/models/task_model.dart';
import '../../../task/presentation/bloc/task_bloc.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDate;
  late int _currentYear;
  late int _currentMonth;
  Map<int, int> _studyMinutesByDay = {};
  Map<int, int> _tasksCompletedByDay = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentYear = _selectedDate.year;
    _currentMonth = _selectedDate.month;
    _loadData();
  }

  void _loadData() {
    context.read<StudyBloc>().add(LoadStudyData());
    _loadSchedulesAndTasksForDate(_selectedDate);
  }

  void _loadSchedulesAndTasksForDate(DateTime date) {
    // Load schedules for selected date
    context.read<ScheduleBloc>().add(LoadSchedulesByDate(date: date));
    // Load tasks for selected date
    context.read<TaskBloc>().add(LoadTasksByDate(date: date, userId: '1'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Calendar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyle.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarHeader(),
            const SizedBox(height: 16),
            _buildCalendarGrid(),
            const SizedBox(height: 24),
            _buildSelectedDateInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              if (_currentMonth == 1) {
                _currentMonth = 12;
                _currentYear--;
              } else {
                _currentMonth--;
              }
            });
          },
        ),
        Text(
          _getMonthYearString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              if (_currentMonth == 12) {
                _currentMonth = 1;
                _currentYear++;
              } else {
                _currentMonth++;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTimeUtils.getDaysInMonth(_currentYear, _currentMonth);
    final firstDayOfMonth = DateTime(_currentYear, _currentMonth, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return NeoContainer(
      padding: const EdgeInsets.all(AppStyle.paddingMedium),
      child: Column(
        children: [
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar days
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayNumber = index - startingWeekday + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox();
              }

              final date = DateTime(_currentYear, _currentMonth, dayNumber);
              final isSelected = DateTimeUtils.isSameDay(date, _selectedDate);
              final isToday = DateTimeUtils.isToday(date);
              final studyMinutes = _studyMinutesByDay[dayNumber] ?? 0;
              final tasksCompleted = _tasksCompletedByDay[dayNumber] ?? 0;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                  _loadSchedulesAndTasksForDate(date);
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                            ? AppColors.primary.withOpacity(0.2)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textMain,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (studyMinutes > 0)
                        Positioned(
                          bottom: 2,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : _getStudyColor(studyMinutes),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      if (tasksCompleted > 0)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateTimeUtils.formatDate(_selectedDate),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Schedules Section
        const Text(
          'Schedules',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<ScheduleBloc, ScheduleState>(
          builder: (context, state) {
            if (state is ScheduleLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ScheduleLoaded) {
              if (state.schedules.isEmpty) {
                return _buildEmptyCard(
                  icon: Icons.event_busy,
                  iconColor: AppColors.primary,
                  message: 'No schedules',
                );
              }
              return Column(
                children: state.schedules.map((schedule) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildScheduleItem(schedule),
                  );
                }).toList(),
              );
            }
            return _buildEmptyCard(
              icon: Icons.event_busy,
              iconColor: AppColors.primary,
              message: 'No schedules',
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Tasks Section
        const Text(
          'Tasks',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TaskLoaded) {
              if (state.tasks.isEmpty) {
                return _buildEmptyCard(
                  icon: Icons.assignment_outlined,
                  iconColor: AppColors.success,
                  message: 'No tasks',
                );
              }
              return Column(
                children: state.tasks.map((task) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildTaskItem(task),
                  );
                }).toList(),
              );
            }
            return _buildEmptyCard(
              icon: Icons.assignment_outlined,
              iconColor: AppColors.success,
              message: 'No tasks',
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required Color iconColor,
    required String message,
  }) {
    return NeoCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(ScheduleEntity schedule) {
    return NeoCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(schedule.color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getScheduleIcon(schedule.icon),
                color: Color(schedule.color),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('HH:mm').format(schedule.startTime)} - ${DateFormat('HH:mm').format(schedule.endTime)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (schedule.recurrence != 'None')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.repeat, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      _getRecurrenceLabel(schedule.recurrence),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task) {
    return NeoCard(
      accentColor: Color(task.color),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? AppColors.success.withOpacity(0.2)
                    : Color(task.color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                task.isCompleted ? Icons.check_circle : Icons.assignment,
                color: task.isCompleted ? AppColors.success : Color(task.color),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (task.subject != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      task.subject!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: _getDeadlineColor(task.deadline, task),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateTimeUtils.formatDateTime(task.deadline),
                        style: TextStyle(
                          fontSize: 11,
                          color: _getDeadlineColor(task.deadline, task),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (task.isPinned)
              const Icon(
                Icons.push_pin,
                size: 16,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  String _getMonthYearString() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[_currentMonth - 1]} $_currentYear';
  }

  Color _getStudyColor(int minutes) {
    if (minutes >= 60) return AppColors.success;
    if (minutes >= 30) return AppColors.primary;
    if (minutes >= 15) return AppColors.warning;
    return AppColors.textSecondary;
  }

  IconData _getScheduleIcon(String? icon) {
    switch (icon) {
      case 'school':
        return Icons.school;
      case 'work':
        return Icons.work;
      case 'book':
        return Icons.menu_book;
      case 'sports':
        return Icons.sports;
      case 'music':
        return Icons.music_note;
      case 'food':
        return Icons.restaurant;
      case 'health':
        return Icons.favorite;
      case 'travel':
        return Icons.flight;
      case 'social':
        return Icons.people;
      case 'game':
        return Icons.sports_esports;
      case 'meeting':
        return Icons.groups;
      default:
        return Icons.event;
    }
  }

  String _getRecurrenceLabel(String recurrence) {
    switch (recurrence) {
      case 'Daily':
        return 'Daily';
      case 'Weekly':
        return 'Weekly';
      case 'Monthly':
        return 'Monthly';
      default:
        return '';
    }
  }

  Color _getDeadlineColor(DateTime deadline, TaskModel task) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (task.isCompleted) return AppColors.success;
    if (difference.isNegative) return AppColors.error;
    if (difference.inHours < 1) return AppColors.error;
    if (difference.inHours < 12) return AppColors.warning;
    return AppColors.textSecondary;
  }
}