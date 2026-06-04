import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../schedule/domain/entities/schedule_entity.dart';
import '../../../schedule/presentation/bloc/schedule_bloc.dart';
import '../../../schedule/presentation/widgets/schedule_form_sheet.dart';
import '../../../study/presentation/bloc/study_bloc.dart';
import '../../../task/domain/entities/task_entity.dart';
import '../../../task/presentation/bloc/task_bloc.dart';
import '../../../task/presentation/widgets/task_form_sheet.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDate;
  late DateTime _visibleMonth;
  Map<int, int> _studyMinutesByDay = {};

  String? get _currentUserId {
    final state = context.read<AuthBloc>().state;
    return state is Authenticated ? state.user.userId : null;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _visibleMonth = DateTime(now.year, now.month);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSelectedDate());
  }

  void _loadSelectedDate() {
    final userId = _currentUserId;
    if (userId == null) return;
    context.read<ScheduleBloc>().add(LoadSchedulesByDate(date: _selectedDate));
    context.read<TaskBloc>().add(
      LoadTasksByDate(date: _selectedDate, userId: userId),
    );
    _loadStudyMonth(userId);
  }

  Future<void> _loadStudyMonth(String userId) async {
    final days = await context
        .read<StudyBloc>()
        .repository
        .getStudyMinutesByDay(userId, _visibleMonth.year, _visibleMonth.month);
    if (!mounted) return;
    setState(() => _studyMinutesByDay = days);
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + offset,
      );
    });
    final userId = _currentUserId;
    if (userId != null) _loadStudyMonth(userId);
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
      _visibleMonth = DateTime(date.year, date.month);
    });
    _loadSelectedDate();
  }

  Future<void> _showAddSheet() async {
    final userId = _currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login ulang untuk menambahkan data.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ScheduleBloc>()),
          BlocProvider.value(value: context.read<TaskBloc>()),
        ],
        child: _CalendarAddSheet(userId: userId),
      ),
    );
    _loadSelectedDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      body: SafeArea(
        child: BlocBuilder<ScheduleBloc, ScheduleState>(
          builder: (context, scheduleState) {
            final schedules = scheduleState is ScheduleLoaded
                ? scheduleState.schedules
                : <ScheduleEntity>[];

            return BlocBuilder<TaskBloc, TaskState>(
              builder: (context, taskState) {
                final tasks = taskState is TaskLoaded
                    ? taskState.tasks
                    : <TaskEntity>[];

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 96),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildTopBar(),
                          const SizedBox(height: 12),
                          _buildMonthPicker(),
                          const SizedBox(height: 14),
                          _buildCalendarGrid(),
                          const SizedBox(height: 16),
                          _buildLegend(),
                          const SizedBox(height: 18),
                          _buildDayPanel(schedules, tasks),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppColors.textMain,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          ),
          Expanded(
            child: Text(
              'Calendar',
              style: AppTextStyles.heading.copyWith(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => _changeMonth(-1),
          icon: const Icon(Icons.chevron_left_rounded),
          color: AppColors.textSecondary,
          constraints: const BoxConstraints.tightFor(width: 34, height: 34),
          padding: EdgeInsets.zero,
        ),
        SizedBox(
          width: 136,
          child: Text(
            DateFormat('MMMM yyyy').format(_visibleMonth),
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(fontSize: 14),
          ),
        ),
        IconButton(
          onPressed: () => _changeMonth(1),
          icon: const Icon(Icons.chevron_right_rounded),
          color: AppColors.textSecondary,
          constraints: const BoxConstraints.tightFor(width: 34, height: 34),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month);
    final firstCell = firstDay.subtract(Duration(days: firstDay.weekday - 1));
    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        Row(
          children: weekDays
              .map(
                (day) => Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 42,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final date = firstCell.add(Duration(days: index));
            return _CalendarDayCell(
              date: date,
              isMuted: date.month != _visibleMonth.month,
              isSelected: _isSameDay(date, _selectedDate),
              intensity: _dayIntensity(date),
              onTap: () => _selectDate(date),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _LegendItem(color: AppColors.white, label: '0h', bordered: true),
        SizedBox(width: 20),
        _LegendItem(color: AppColors.primaryLight, label: '>4h'),
        SizedBox(width: 20),
        _LegendItem(color: AppColors.primary, label: '>6h'),
        SizedBox(width: 20),
        _LegendItem(color: AppColors.primaryDark, label: '>8h'),
      ],
    );
  }

  Widget _buildDayPanel(
    List<ScheduleEntity> schedules,
    List<TaskEntity> tasks,
  ) {
    final totalMinutes = _studyMinutesByDay[_selectedDate.day] ?? 0;
    final doneTasks = tasks.where((task) => task.isCompleted).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.greyBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('MMM d, yyyy').format(_selectedDate),
                  style: AppTextStyles.title.copyWith(fontSize: 14),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSummary(totalMinutes, doneTasks, schedules.length),
          const SizedBox(height: 18),
          Text('Schedules', style: AppTextStyles.title.copyWith(fontSize: 13)),
          const SizedBox(height: 10),
          if (schedules.isEmpty)
            _EmptyLine(icon: Icons.event_busy_rounded, label: 'No schedules')
          else
            ...schedules.map(_ScheduleLine.new),
          const SizedBox(height: 16),
          Text('Tasks', style: AppTextStyles.title.copyWith(fontSize: 13)),
          const SizedBox(height: 10),
          if (tasks.isEmpty)
            _EmptyLine(icon: Icons.task_alt_rounded, label: 'No tasks')
          else
            ...tasks.map(_TaskLine.new),
        ],
      ),
    );
  }

  Widget _buildSummary(int minutes, int doneTasks, int scheduleCount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _SummaryItem(
            value: _formatDuration(minutes),
            label: 'Total study time',
            valueColor: AppColors.success,
          ),
          _SummaryDivider(),
          _SummaryItem(value: '$doneTasks', label: 'Tasks done'),
          _SummaryDivider(),
          _SummaryItem(value: '$scheduleCount', label: 'Schedules'),
        ],
      ),
    );
  }

  int _dayIntensity(DateTime date) {
    if (date.month != _visibleMonth.month) return 0;
    final minutes = _studyMinutesByDay[date.day] ?? 0;
    if (minutes >= 8 * 60) return 3;
    if (minutes >= 6 * 60) return 2;
    if (minutes >= 4 * 60) return 1;
    return 0;
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) return '0h';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool isMuted;
  final bool isSelected;
  final int intensity;
  final VoidCallback onTap;

  const _CalendarDayCell({
    required this.date,
    required this.isMuted,
    required this.isSelected,
    required this.intensity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (intensity) {
      3 => AppColors.primary,
      2 => AppColors.primaryBorder,
      1 => AppColors.primaryLight,
      _ => AppColors.transparent,
    };
    final hasFill = intensity > 0 || isSelected;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : color,
          shape: BoxShape.circle,
        ),
        child: Text(
          '${date.day}',
          style: AppTextStyles.small.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? AppColors.white
                : isMuted
                ? AppColors.textMuted
                : hasFill
                ? AppColors.primaryDark
                : AppColors.textMain,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool bordered;

  const _LegendItem({
    required this.color,
    required this.label,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: bordered ? Border.all(color: AppColors.greyBorder) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _SummaryItem({
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              fontSize: 14,
              color: valueColor ?? AppColors.textMain,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: AppColors.greyBorder);
  }
}

class _ScheduleLine extends StatelessWidget {
  final ScheduleEntity schedule;

  const _ScheduleLine(this.schedule);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: Color(schedule.color),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 76,
            child: Text(
              '${DateFormat('HH.mm').format(schedule.startTime)} - ${DateFormat('HH.mm').format(schedule.endTime)}',
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: AppColors.textMain,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              schedule.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskLine extends StatelessWidget {
  final TaskEntity task;

  const _TaskLine(this.task);

  @override
  Widget build(BuildContext context) {
    final color = task.isCompleted ? AppColors.success : Color(task.color);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.4),
            ),
            child: task.isCompleted
                ? Icon(Icons.check_rounded, size: 12, color: color)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                fontSize: 11,
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EmptyLine({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

class _CalendarAddSheet extends StatelessWidget {
  final String userId;

  const _CalendarAddSheet({required this.userId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyHandle,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              height: 42,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(13),
                ),
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.tabActive.copyWith(
                  color: AppColors.white,
                ),
                unselectedLabelStyle: AppTextStyles.tabInactive,
                dividerColor: AppColors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Schedule'),
                  Tab(text: 'Task'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  BlocProvider.value(
                    value: context.read<ScheduleBloc>(),
                    child: ScheduleFormSheet(userId: userId),
                  ),
                  BlocProvider.value(
                    value: context.read<TaskBloc>(),
                    child: TaskFormSheet(userId: userId),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
