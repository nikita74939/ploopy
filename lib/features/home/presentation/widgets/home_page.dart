import 'package:flutter/material.dart';
import '../../../../core/constants/schedule_dummy_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/session_service.dart';
import 'urgent_schedule_banner.dart';
import 'urgent_task_banner.dart';
import 'schedule_timeline.dart';
import 'home_header_simple.dart';

class HomeBerandaPage extends StatefulWidget {
  const HomeBerandaPage({super.key});

  @override
  State<HomeBerandaPage> createState() => _HomeBerandaPageState();
}

class _HomeBerandaPageState extends State<HomeBerandaPage> {
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    await SessionService.getCurrentUser();
    if (!mounted) return;
    setState(() => _loadingUser = false);
  }

  String _getDateString() {
    final now = DateTime.now();
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}';
  }

  String _getStudyTime() {
    final totalMinutes = ScheduleDummyData.todayItems
        .where((item) => item['done'] == true)
        .fold<int>(0, (sum, item) => sum + (item['durationNum'] as int? ?? 0));

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final seconds = 0;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic>? _getUpcomingSchedule() {
    final items = ScheduleDummyData.todayItems;
    for (final item in items) {
      if (!(item['done'] as bool? ?? false)) {
        return item;
      }
    }
    return items.isNotEmpty ? items.first : null;
  }

  Map<String, dynamic>? _getUrgentTask() {
    final tasks = ScheduleDummyData.todayTasks;
    if (tasks.isEmpty) return null;

    final priority = {'Kemarin': 0, 'Hari ini': 1, 'Besok': 2};
    final uncompleted =
        tasks.where((t) => !(t['done'] as bool? ?? false)).toList();
    final listToSort = uncompleted.isNotEmpty ? uncompleted : tasks;

    listToSort.sort((a, b) {
      final dueA = a['due'] as String? ?? '';
      final dueB = b['due'] as String? ?? '';
      final prioA = priority[dueA] ?? 99;
      final prioB = priority[dueB] ?? 99;
      return prioA.compareTo(prioB);
    });

    return listToSort.first;
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    final upcomingSchedule = _getUpcomingSchedule();
    final urgentTask = _getUrgentTask();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          HomeHeaderSimple(
            dateString: _getDateString(),
            studyTime: _getStudyTime(),
            onCalendarTap: () {
              // TODO: Navigate to calendar page
            },
            onNotificationTap: () {
              Navigator.pushNamed(context, '/notification');
            },
            onStartTap: () {
              // TODO: Navigate to study desk page
            },
          ),
          Expanded(
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: [0, 0.04, 0.94, 1],
                ).createShader(bounds);
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    if (upcomingSchedule != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: UrgentScheduleBanner(
                          item: upcomingSchedule,
                          onTap: () {
                            // TODO: navigate to schedule detail
                          },
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                    if (urgentTask != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: UrgentTaskBanner(
                          item: urgentTask,
                          onTap: () {
                            // TODO: navigate to task detail
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ScheduleTimeline(
                        scheduleItems: ScheduleDummyData.todayItems,
                        taskItems: ScheduleDummyData.todayTasks,
                        onSeeAll: () {
                          // TODO: navigate to full schedule
                        },
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
