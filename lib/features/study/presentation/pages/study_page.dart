import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../schedule/domain/entities/schedule_entity.dart';
import '../../../schedule/presentation/bloc/schedule_bloc.dart';
import '../../../task/domain/entities/task_entity.dart';
import '../../../task/presentation/bloc/task_bloc.dart';
import '../bloc/study_bloc.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  String? _loadedUserId;

  String? get _currentUserId {
    final state = context.read<AuthBloc>().state;
    return state is Authenticated ? state.user.userId : null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final userId = _currentUserId;
    if (userId == null) return;
    _loadedUserId = userId;
    context.read<StudyBloc>().add(LoadStudyData(userId: userId));
    context.read<ScheduleBloc>().add(
      LoadSchedulesByDate(userId: userId, date: DateTime.now()),
    );
    context.read<TaskBloc>().add(
      LoadTasksByDate(date: DateTime.now(), userId: userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<StudyBloc, StudyState>(
          builder: (context, studyState) {
            return BlocBuilder<ScheduleBloc, ScheduleState>(
              builder: (context, scheduleState) {
                final schedules = scheduleState is ScheduleLoaded
                    ? scheduleState.schedules
                    : <ScheduleEntity>[];

                return BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, taskState) {
                    final tasks = taskState is TaskLoaded
                        ? taskState.tasks
                        : <TaskEntity>[];

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async => _loadData(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTopBar(),
                            const SizedBox(height: 12),
                            _FocusModeCard(
                              state: studyState,
                              onStart: _startFocus,
                              onPause: () => context.read<StudyBloc>().add(
                                PauseStudySession(),
                              ),
                              onResume: () => context.read<StudyBloc>().add(
                                ResumeStudySession(),
                              ),
                              onStop: () => context.read<StudyBloc>().add(
                                EndStudySession(),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _buildModeRow(studyState),
                            const SizedBox(height: 14),
                            _ProgressCard(state: studyState, tasks: tasks),
                            const SizedBox(height: 14),
                            _ScheduleSection(schedules: schedules),
                            const SizedBox(height: 14),
                            _UrgentTaskSection(tasks: tasks),
                          ],
                        ),
                      ),
                    );
                  },
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
              'Study Desk',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading.copyWith(fontSize: 18),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildModeRow(StudyState state) {
    return Row(
      children: [
        Expanded(
          child: _ModeTile(
            icon: Icons.av_timer_rounded,
            title: 'Short Break',
            subtitle: '5 min',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ModeTile(
            icon: Icons.timer_rounded,
            title: 'Long Break',
            subtitle: '15 min',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ModeTile(
            icon: Icons.stop_circle_outlined,
            title: 'Stop Focus',
            subtitle: state is StudyInProgress || state is StudyPaused
                ? 'End now'
                : 'Ready',
            onTap: () {
              if (state is StudyInProgress || state is StudyPaused) {
                context.read<StudyBloc>().add(EndStudySession());
              }
            },
            accent: AppColors.error,
          ),
        ),
      ],
    );
  }

  void _startFocus() {
    final userId = _loadedUserId ?? _currentUserId;
    if (userId == null) return;
    context.read<StudyBloc>().add(StartStudySession(userId: userId));
  }
}

class _FocusModeCard extends StatelessWidget {
  final StudyState state;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const _FocusModeCard({
    required this.state,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final elapsed = switch (state) {
      StudyInProgress(:final elapsedSeconds) => elapsedSeconds,
      StudyPaused(:final elapsedSeconds) => elapsedSeconds,
      _ => 0,
    };
    final remaining = math.max(0, 25 * 60 - elapsed);
    final progress = (elapsed / (25 * 60)).clamp(0.0, 1.0);
    final isRunning = state is StudyInProgress;
    final isPaused = state is StudyPaused;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.primaryLight, width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Focus Mode',
                style: AppTextStyles.title.copyWith(fontSize: 14),
              ),
              const Spacer(),
              Text(
                'Pomodoro',
                style: AppTextStyles.link.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 184,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(168, 168),
                  painter: _TimerRingPainter(progress: progress),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTimer(remaining),
                      style: AppTextStyles.display.copyWith(
                        fontSize: 38,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isPaused ? 'Paused' : "Let's focus!",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isRunning ? onPause : (isPaused ? onResume : onStart),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Text(
                isRunning
                    ? 'Pause Focus'
                    : isPaused
                    ? 'Resume Focus'
                    : 'Start Focus',
                style: AppTextStyles.buttonPrimary.copyWith(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;

  const _TimerRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = AppColors.primaryLight;
    canvas.drawArc(rect, math.pi * 0.72, math.pi * 1.56, false, stroke);
    stroke.color = AppColors.primary;
    canvas.drawArc(
      rect,
      math.pi * 0.72,
      math.pi * 1.56 * progress,
      false,
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _DeskMascot extends StatelessWidget {
  const _DeskMascot();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.primaryBorder),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 17,
                top: 17,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.textMain,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 17,
                top: 17,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.textMain,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: 23,
                top: 30,
                child: Container(
                  width: 12,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: AppColors.greenAccent,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _Plant extends StatelessWidget {
  const _Plant();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 78,
      child: Stack(
        children: [
          Positioned(
            left: 18,
            bottom: 24,
            child: Container(width: 4, height: 36, color: AppColors.success),
          ),
          Positioned(
            left: 3,
            top: 10,
            child: Icon(Icons.eco_rounded, color: AppColors.success, size: 34),
          ),
          Positioned(
            right: 0,
            top: 26,
            child: Icon(
              Icons.eco_rounded,
              color: AppColors.tealAccent,
              size: 28,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 8,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.creamDeep,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.greyBorder),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Lamp extends StatelessWidget {
  const _Lamp();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 76,
      child: Stack(
        children: [
          Positioned(
            right: 14,
            bottom: 13,
            child: Container(width: 4, height: 44, color: AppColors.primary),
          ),
          Positioned(
            right: 0,
            top: 7,
            child: Icon(
              Icons.light_rounded,
              color: AppColors.primary,
              size: 42,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 2,
            child: Container(
              width: 42,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.creamDeep,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color accent;

  const _ModeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 86,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.greyBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accent, size: 28),
            const SizedBox(height: 7),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMain,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            Text(subtitle, style: AppTextStyles.caption.copyWith(fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final StudyState state;
  final List<TaskEntity> tasks;

  const _ProgressCard({required this.state, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final minutes = switch (state) {
      StudyIdle(:final todayStudyMinutes) => todayStudyMinutes,
      StudyInProgress(:final todayStudyMinutes, :final elapsedSeconds) =>
        todayStudyMinutes + elapsedSeconds ~/ 60,
      StudyPaused(:final todayStudyMinutes, :final elapsedSeconds) =>
        todayStudyMinutes + elapsedSeconds ~/ 60,
      _ => 0,
    };
    final done = tasks.where((task) => task.isCompleted).length;
    const targetMinutes = 360;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today Progress',
            style: AppTextStyles.title.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ProgressMetric(
                  label: 'Study Time',
                  value: _formatMinutes(minutes),
                  suffix: '/6h',
                  progress: (minutes / targetMinutes).clamp(0.0, 1.0),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _ProgressMetric(
                  label: 'Tasks Done',
                  value: '$done',
                  suffix: '/${tasks.length}',
                  progress: tasks.isEmpty ? 0 : done / tasks.length,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }
}

class _ProgressMetric extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;
  final double progress;

  const _ProgressMetric({
    required this.label,
    required this.value,
    required this.suffix,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: AppTextStyles.title.copyWith(fontSize: 18)),
            const SizedBox(width: 3),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                suffix,
                style: AppTextStyles.caption.copyWith(fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: AppColors.primaryLighter,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  final List<ScheduleEntity> schedules;

  const _ScheduleSection({required this.schedules});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: "Today's Schedule",
      action: 'View All',
      child: schedules.isEmpty
          ? const _EmptyRow(label: 'No schedules for today')
          : Column(
              children: schedules.take(4).map((schedule) {
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
                        width: 82,
                        child: Text(
                          '${DateFormat('HH.mm').format(schedule.startTime)} - ${DateFormat('HH.mm').format(schedule.endTime)}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMain,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
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
              }).toList(),
            ),
    );
  }
}

class _UrgentTaskSection extends StatelessWidget {
  final List<TaskEntity> tasks;

  const _UrgentTaskSection({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final sorted = [...tasks]..sort((a, b) => a.deadline.compareTo(b.deadline));
    TaskEntity? task;
    for (final item in sorted) {
      if (!item.isCompleted) {
        task = item;
        break;
      }
    }

    return _SectionCard(
      title: 'Most Urgent Task',
      child: task == null
          ? const _EmptyRow(label: 'No urgent task')
          : Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Color(task.color).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.task_alt_rounded, color: Color(task.color)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Deadline: ${DateFormat('EEE, d MMM').format(task.deadline)}',
                        style: AppTextStyles.caption.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'High Priority',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.error,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? action;
  final Widget child;

  const _SectionCard({required this.title, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.title.copyWith(fontSize: 14),
                ),
              ),
              if (action != null)
                Text(action!, style: AppTextStyles.link.copyWith(fontSize: 10)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final String label;

  const _EmptyRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: 16,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
      ],
    );
  }
}
