import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../notification/presentation/pages/notification_page.dart';
import '../../../schedule/data/models/schedule_model.dart';
import '../../../task/data/models/task_model.dart';
import '../bloc/home_bloc.dart';
import 'home_greeting_header.dart';
import 'learn_now_banner.dart' show LearnNowBanner;
import 'mini_calendar.dart';
import 'schedule_timeline.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedDay = DateTime.now().day;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadHomeData());
  }

  // ── Helper: iconName string → IconData ──────────────────────────────────
  IconData _resolveIcon(String? iconName, IconData fallback) {
    switch (iconName) {
      case 'book':
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'math':
      case 'calculate':
        return Icons.calculate_rounded;
      case 'history':
        return Icons.history_edu_rounded;
      case 'art':
      case 'palette':
        return Icons.palette_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'sport':
        return Icons.sports_rounded;
      case 'code':
        return Icons.code_rounded;
      case 'language':
        return Icons.translate_rounded;
      case 'event':
        return Icons.event_rounded;
      case 'task':
        return Icons.task_alt_rounded;
      default:
        return fallback;
    }
  }

  // ── Helper: format durasi dari dua DateTime ──────────────────────────────
  String _formatDuration(DateTime start, DateTime end) {
    final diff = end.difference(start);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0 && minutes > 0) return '${hours}j ${minutes}mnt';
    if (hours > 0) return '${hours}j';
    return '${minutes}mnt';
  }

  // ── Helper: format jam HH:mm ─────────────────────────────────────────────
  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ── Mapping ScheduleModel → Map<String, dynamic> ────────────────────────
  // Field: name, startTime, endTime, color (int), iconName
  List<Map<String, dynamic>> _mapSchedules(List<ScheduleModel> schedules) {
    return schedules.map((s) {
      return {
        'time': _formatTime(s.startTime),
        'title': s.name,
        'streak': '',
        'duration': _formatDuration(s.startTime, s.endTime),
        'icon': _resolveIcon(s.iconName, Icons.event_rounded),
        'color': Color(s.color),
        'done': false,
      };
    }).toList();
  }

  // ── Mapping TaskModel → Map<String, dynamic> ────────────────────────────
  // Field: name, subject, deadline, color (int), iconName, isCompleted
  List<Map<String, dynamic>> _mapTasks(List<TaskModel> tasks) {
    return tasks.map((t) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final deadlineDay = DateTime(
        t.deadline.year,
        t.deadline.month,
        t.deadline.day,
      );
      final diff = deadlineDay.difference(today).inDays;

      final String dueLabel;
      if (diff < 0) {
        dueLabel = 'Kemarin';
      } else if (diff == 0) {
        dueLabel = 'Hari ini';
      } else if (diff == 1) {
        dueLabel = 'Besok';
      } else {
        dueLabel = '+$diff hari';
      }

      return {
        'title': t.name,
        'subject': t.subject ?? '',
        'due': dueLabel,
        'icon': _resolveIcon(t.iconName, Icons.task_alt_rounded),
        'color': Color(t.color),
        'done': t.isCompleted,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // ── Ambil nama user dari AuthBloc ────────────────────────────────
        final String name;
        if (authState is Authenticated) {
          name = authState.user.name;
        } else if (authState is AuthLoading || authState is AuthInitial) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          );
        } else {
          name = 'Pengguna';
        }

        return SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<HomeBloc>().add(RefreshHomeData());
              await Future.delayed(const Duration(milliseconds: 600));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header Greeting ───────────────────────────────────
                  HomeGreetingHeader(
                    name: name,
                    unreadNotifCount: 3,
                    onNotifTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Mini Calendar ─────────────────────────────────────
                  MiniCalendar(
                    selectedDay: _selectedDay,
                    onDaySelected: (day) => setState(() => _selectedDay = day),
                  ),
                  const SizedBox(height: 20),

                  // ── Banner Belajar ────────────────────────────────────
                  LearnNowBanner(
                    onTap: () {
                      // TODO: navigate to desk page
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Schedule & Task dari HomeBloc ─────────────────────
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, homeState) {
                      if (homeState is HomeLoading ||
                          homeState is HomeInitial) {
                        return const _ScheduleSkeleton();
                      }

                      if (homeState is HomeError) {
                        return _ErrorCard(
                          message: homeState.message,
                          onRetry: () =>
                              context.read<HomeBloc>().add(LoadHomeData()),
                        );
                      }

                      if (homeState is HomeLoaded) {
                        return ScheduleTimeline(
                          scheduleItems: _mapSchedules(
                            homeState.todaySchedules,
                          ),
                          taskItems: _mapTasks(homeState.tasks),
                          onSeeAll: () {
                            // TODO: navigate to full schedule
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Skeleton Loading ───────────────────────────────────────────────────────────
class _ScheduleSkeleton extends StatelessWidget {
  const _ScheduleSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SkeletonBox(width: 120, height: 18, radius: 6),
            _SkeletonBox(width: 150, height: 34, radius: 12),
          ],
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < 3; i++) ...[
          _SkeletonBox(width: double.infinity, height: 66, radius: 14),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Error Card ─────────────────────────────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, size: 32, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(
            'Gagal memuat data',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Text(
                'Coba lagi',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
