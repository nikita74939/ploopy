import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/schedule_entity.dart';
import '../bloc/schedule_bloc.dart';
import 'add_schedule_page.dart';
import 'detail_schedule_page.dart';

// Ganti dengan cara yang sesuai di proyekmu untuk mendapatkan userId aktif
const _kCurrentUserId = '1';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  void initState() {
    super.initState();
    context
        .read<ScheduleBloc>()
        .add(LoadSchedules(userId: _kCurrentUserId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.calendar);
            },
          ),
        ],
      ),
      body: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ScheduleLoaded) {
            if (state.schedules.isEmpty) {
              return _buildEmptyState();
            }
            return _buildScheduleList(state.schedules);
          }

          if (state is ScheduleError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<ScheduleBloc>(),
              child: const AddSchedulePage(),
            ),
          ),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada jadwal',
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + untuk menambahkan jadwal pertamamu',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(List<ScheduleEntity> schedules) {
    // Kelompokkan jadwal berdasarkan tanggal
    final Map<String, List<ScheduleEntity>> grouped = {};
    for (final schedule in schedules) {
      final dateKey = DateTimeUtils.formatDate(schedule.startTime);
      grouped.putIfAbsent(dateKey, () => []).add(schedule);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppStyle.paddingMedium),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dateKey = grouped.keys.elementAt(index);
        final daySchedules = grouped[dateKey]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                dateKey,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
            ),
            ...daySchedules.map(
              (schedule) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildScheduleCard(schedule),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScheduleCard(ScheduleEntity schedule) {
    return Dismissible(
      key: Key(schedule.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppStyle.borderRadius),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Jadwal'),
            content: const Text('Yakin ingin menghapus jadwal ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context.read<ScheduleBloc>().add(
              DeleteSchedule(id: schedule.id, userId: schedule.userId),
            );
      },
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<ScheduleBloc>(),
              child: DetailSchedulePage(schedule: schedule),
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppStyle.borderRadius),
            border: Border(
              left: BorderSide(color: Color(schedule.color), width: 4),
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.border,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppStyle.paddingMedium),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(schedule.color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconFromName(schedule.icon),
                    color: Color(schedule.color),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateTimeUtils.formatTime(schedule.startTime)} - ${DateTimeUtils.formatTime(schedule.endTime)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (schedule.location?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                schedule.location!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (schedule.recurrence != 'None') ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.repeat,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getRecurrenceLabel(schedule.recurrence),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconFromName(String? iconName) {
    switch (iconName) {
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