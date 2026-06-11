import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/schedule_entity.dart';
import '../bloc/schedule_bloc.dart';
import '../widgets/schedule_calendar_strip.dart';
import '../widgets/schedule_form_sheet.dart';
import 'detail_schedule_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  String? _currentUserId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadForCurrentUser();
  }

  void _loadForCurrentUser() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.userId;
      context.read<ScheduleBloc>().add(
        LoadSchedulesByDate(userId: _currentUserId!, date: _selectedDate),
      );
    }
  }

  void _showScheduleSheet({ScheduleEntity? schedule}) {
    final userId = schedule?.userId ?? _currentUserId;
    if (userId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ScheduleBloc>(),
        child: ScheduleFormSheet(
          userId: userId,
          schedule: schedule,
          initialDate: schedule == null ? _selectedDate : null,
        ),
      ),
    );
  }

  void _selectDate(DateTime date) {
    final userId = _currentUserId;
    if (userId == null) return;
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
    });
    context.read<ScheduleBloc>().add(
      LoadSchedulesByDate(userId: userId, date: _selectedDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Kalender',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.calendar),
          ),
        ],
      ),
      body: BlocConsumer<ScheduleBloc, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ScheduleLoading || state is ScheduleInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ScheduleLoaded) {
            return _buildScheduleContent(state.schedules);
          }

          if (state is ScheduleError) {
            return _buildMessageState(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat jadwal',
              subtitle: state.message,
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleSheet(),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildScheduleContent(List<ScheduleEntity> schedules) {
    final scheduleDates = schedules
        .map(
          (schedule) => DateTime(
            schedule.startTime.year,
            schedule.startTime.month,
            schedule.startTime.day,
          ),
        )
        .toSet();

    return Column(
      children: [
        ScheduleCalendarStrip(
          selectedDate: _selectedDate,
          scheduleDates: scheduleDates,
          onDateSelected: _selectDate,
        ),
        Expanded(
          child: schedules.isEmpty
              ? _buildEmptyState()
              : _buildScheduleList(schedules),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return _buildMessageState(
      icon: Icons.event_busy_rounded,
      title: 'Belum ada jadwal',
      subtitle: 'Tekan tombol tambah untuk membuat jadwal di tanggal ini.',
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: AppColors.primary.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 14),
            Text(title, style: AppTextStyles.heading),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleList(List<ScheduleEntity> schedules) {
    final grouped = <String, List<ScheduleEntity>>{};
    for (final schedule in schedules) {
      final dateKey = DateTimeUtils.formatDate(schedule.startTime);
      grouped.putIfAbsent(dateKey, () => []).add(schedule);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 10),
              child: Text(
                entry.key,
                style: AppTextStyles.title.copyWith(color: AppColors.primary),
              ),
            ),
            ...entry.value.map(_buildScheduleCard),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildScheduleCard(ScheduleEntity schedule) {
    final color = Color(schedule.color);

    return Dismissible(
      key: ValueKey(schedule.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.white),
      ),
      confirmDismiss: (_) => _confirmDeleteSchedule(schedule),
      onDismissed: (_) {
        context.read<ScheduleBloc>().add(
          DeleteSchedule(id: schedule.id, userId: schedule.userId),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<ScheduleBloc>(),
                  child: DetailSchedulePage(schedule: schedule),
                ),
              ),
            ),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.greyBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_iconFromName(schedule.icon), color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${DateTimeUtils.formatTime(schedule.startTime)} - ${DateTimeUtils.formatTime(schedule.endTime)}',
                          style: AppTextStyles.bodySmall,
                        ),
                        if (schedule.recurrence != 'None') ...[
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.repeat_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _recurrenceLabel(schedule.recurrence),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Edit jadwal',
                    onPressed: () => _showScheduleSheet(schedule: schedule),
                    icon: const Icon(Icons.edit_outlined),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDeleteSchedule(ScheduleEntity schedule) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Hapus Jadwal', style: AppTextStyles.heading),
            content: Text(
              'Yakin ingin menghapus "${schedule.name}"?',
              style: AppTextStyles.body,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
  }

  IconData _iconFromName(String? iconName) {
    switch (iconName) {
      case 'school':
        return Icons.school_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'book':
        return Icons.menu_book_rounded;
      case 'sports':
        return Icons.sports_soccer_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      case 'health':
        return Icons.favorite_rounded;
      case 'travel':
        return Icons.flight_rounded;
      case 'social':
        return Icons.people_rounded;
      case 'game':
        return Icons.sports_esports_rounded;
      case 'meeting':
        return Icons.groups_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  String _recurrenceLabel(String recurrence) {
    switch (recurrence) {
      case 'Daily':
        return 'Setiap Hari';
      case 'Weekly':
        return 'Setiap Minggu';
      case 'Monthly':
        return 'Setiap Bulan';
      default:
        return '';
    }
  }
}
