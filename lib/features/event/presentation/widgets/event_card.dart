// event/presentation/widgets/event_card.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final joined = event['joined'] as bool;
    final hasDistance = event['distance'] != null;
    final hasImage = event['imageUrl'] != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.greyBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Image
            if (hasImage)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: AppColors.greyLight,
                  child: Image.network(
                    event['imageUrl'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: event['coverColor'] as Color? ?? AppColors.greyLight,
                      alignment: Alignment.center,
                      child: Text(
                        event['emoji'] as String,
                        style: AppTextStyles.heading.copyWith(
                          color: AppColors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.greyLight,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (!hasImage) _buildCover(),
                      if (!hasImage) const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCategoryBadge(),
                            const SizedBox(height: 4),
                            Text(
                              event['title'] as String,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildJoinButton(joined),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.calendar_today_outlined,
                    '${event['date']} · ${event['time']}',
                  ),
                  const SizedBox(height: 7),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    hasDistance
                        ? '${event['location']} · ${event['distance']}'
                        : event['location'] as String,
                  ),
                  const SizedBox(height: 12),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: event['coverColor'] as Color? ?? AppColors.greyLight,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        event['emoji'] as String,
        style: AppTextStyles.small.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        event['category'] as String,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.grey),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.small.copyWith(color: AppColors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final participants = event['participants'] as int;
    final max = event['maxParticipants'] as int;
    final percentage = participants / max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$participants / $max peserta',
              style: AppTextStyles.small.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
            const Spacer(),
            Text(
              '${(percentage * 100).round()}%',
              style: AppTextStyles.caption.copyWith(color: AppColors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 4,
            backgroundColor: AppColors.greyLight,
            valueColor: const AlwaysStoppedAnimation(AppColors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildJoinButton(bool joined) {
    return GestureDetector(
      onTap: () {
        // Handle join action
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: joined ? AppColors.greyLight : AppColors.black,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: joined ? AppColors.greyBorder : AppColors.black,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              joined ? Icons.check_rounded : Icons.add_rounded,
              size: 14,
              color: joined ? AppColors.grey : AppColors.white,
            ),
            const SizedBox(width: 4),
            Text(
              joined ? 'Joined' : 'Join',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: joined ? AppColors.grey : AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}