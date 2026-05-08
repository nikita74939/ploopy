import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/neo_container.dart';
import '../../../../core/widgets/neo_card.dart' hide NeoCard;
import '../../../../core/utils/date_utils.dart';
import '../bloc/study_bloc.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  @override
  void initState() {
    super.initState();
    context.read<StudyBloc>().add(LoadStudyData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Study Session'),
      ),
      body: BlocConsumer<StudyBloc, StudyState>(
        listener: (context, state) {
          // Handle state changes
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppStyle.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(state),
                const SizedBox(height: 24),
                _buildFocusCard(state),
                const SizedBox(height: 24),
                _buildStatsCard(state),
                const SizedBox(height: 24),
                _buildTodaySchedule(),
                const SizedBox(height: 24),
                _buildTodayTasks(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(dynamic state) {
    int todayMinutes = 0;
    int streak = 0;

    if (state is StudyIdle) {
      todayMinutes = state.todayStudyMinutes;
      streak = state.streak;
    } else if (state is StudyInProgress) {
      todayMinutes = state.todayStudyMinutes;
      streak = state.streak;
    } else if (state is StudyPaused) {
      todayMinutes = state.todayStudyMinutes;
      streak = state.streak;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Study",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${todayMinutes ~/ 60}h ${todayMinutes % 60}m',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.orangeAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.orangeAccent),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department, color: AppColors.orangeAccent),
              const SizedBox(width: 4),
              Text(
                '$streak day streak',
                style: const TextStyle(
                  color: AppColors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFocusCard(dynamic state) {
    bool isInProgress = state is StudyInProgress;
    bool isPaused = state is StudyPaused;
    int elapsedSeconds = 0;

    if (isInProgress) {
      elapsedSeconds = (state).elapsedSeconds;
    } else if (isPaused) {
      elapsedSeconds = (state).elapsedSeconds;
    }

    return NeoContainer(
      padding: const EdgeInsets.all(AppStyle.paddingLarge),
      child: Column(
        children: [
          const Text(
            'Focus Time',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            DateTimeUtils.formatDuration(Duration(seconds: elapsedSeconds)),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isInProgress && !isPaused) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<StudyBloc>().add(StartStudySession());
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ] else if (isInProgress) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<StudyBloc>().add(PauseStudySession());
                  },
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<StudyBloc>().add(EndStudySession());
                  },
                  icon: const Icon(Icons.stop),
                  label: const Text('End'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ] else if (isPaused) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<StudyBloc>().add(ResumeStudySession());
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Resume'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<StudyBloc>().add(EndStudySession());
                  },
                  icon: const Icon(Icons.stop),
                  label: const Text('End'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isInProgress
                ? 'Stay focused! 🎯'
                : isPaused
                    ? 'Take a break, resume when ready'
                    : 'Press Start to begin your study session',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(dynamic state) {
    int totalFocusMinutes = 0;

    if (state is StudyIdle) {
      totalFocusMinutes = state.sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    }

    return Row(
      children: [
        Expanded(
          child: NeoCard(
            backgroundColor: AppColors.blueAccent.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.timer, color: AppColors.blueAccent, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    '${totalFocusMinutes ~/ 60}h ${totalFocusMinutes % 60}m',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blueAccent,
                    ),
                  ),
                  const Text(
                    'Total Focus',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: NeoCard(
            backgroundColor: AppColors.purpleAccent.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.timelapse, color: AppColors.purpleAccent, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    state is StudyIdle ? '${state.sessions.length}' : '0',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.purpleAccent,
                    ),
                  ),
                  const Text(
                    'Sessions',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodaySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Schedule",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 12),
        NeoCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No schedules for today',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTasks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Tasks",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 12),
        NeoCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.assignment, color: AppColors.secondary),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No tasks due today',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}