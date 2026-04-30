import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/services/event_service.dart';
import '../../../event/domain/event_model.dart';

class SocialEventTab extends StatelessWidget {
  final Function(Event) onTapEvent;
  final VoidCallback onCreateEvent;

  const SocialEventTab({
    super.key,
    required this.onTapEvent,
    required this.onCreateEvent,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Event>>(
      future: EventService.getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {},
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              return _EventCard(
                event: events[i],
                onTap: () => onTapEvent(events[i]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 44,
              color: AppColors.greyHint,
            ),
            const SizedBox(height: 14),
            Text(
              'Belum ada event',
              style: AppTextStyles.heading.copyWith(color: AppColors.black),
            ),
            const SizedBox(height: 4),
            Text(
              'Buat agenda belajar, workshop, atau diskusi kampus.',
              textAlign: TextAlign.center,
              style: AppTextStyles.small.copyWith(height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onCreateEvent,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(
                'Buat Event',
                style: AppTextStyles.small.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.greyBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              if (event.description.isNotEmpty)
                Text(
                  event.description,
                  style: AppTextStyles.small.copyWith(height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    Icons.calendar_today_outlined,
                    _formatDate(event.dateTime),
                  ),
                  _buildInfoChip(
                    Icons.access_time_rounded,
                    _formatTime(event.dateTime),
                  ),
                  _buildInfoChip(
                    Icons.group_outlined,
                    '${event.currentParticipants}/${event.maxParticipants}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.greyBorder),
          ),
          child: Icon(
            Icons.event_note_outlined,
            size: 20,
            color: AppColors.black,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                event.location ?? 'Online',
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final isFull = event.currentParticipants >= event.maxParticipants;
    final text =
        isFull
            ? 'Penuh'
            : event.isUpcoming
            ? 'Aktif'
            : 'Selesai';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.greyLighter,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.greyLighter,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.grey),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
