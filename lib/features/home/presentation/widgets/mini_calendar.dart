import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_helper.dart';

class MiniCalendar extends StatelessWidget {
  final int selectedDay;
  final ValueChanged<int> onDaySelected;
  final VoidCallback? onOpenCalendar;
  final Map<int, int> activityMinutesByDay;

  const MiniCalendar({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    this.onOpenCalendar,
    this.activityMinutesByDay = const {},
  });

  @override
  Widget build(BuildContext context) {
    final weekDates = DateHelper.getCurrentWeekDates();
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateHelper.formatMonthYear(now),
                style: AppTextStyles.title.copyWith(fontSize: 13),
              ),
              GestureDetector(
                onTap: () {
                  if (onOpenCalendar != null) {
                    onOpenCalendar!();
                  } else {
                    _showComingSoon(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Calendar',
                        style: AppTextStyles.buttonPrimary.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final d = weekDates[i];
              final isSelected = d.day == selectedDay;
              final minutes = activityMinutesByDay[d.day] ?? 0;
              return _DayItem(
                label: DateHelper.dayNames[i],
                day: d.day,
                isSelected: isSelected,
                activityMinutes: minutes,
                onTap: () => onDaySelected(d.day),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Kalender lengkap segera hadir!',
          style: AppTextStyles.body.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.textMain,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _DayItem extends StatelessWidget {
  final String label;
  final int day;
  final bool isSelected;
  final int activityMinutes;
  final VoidCallback onTap;

  const _DayItem({
    required this.label,
    required this.day,
    required this.isSelected,
    required this.activityMinutes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasActivity = activityMinutes > 0;
    final intensity = activityMinutes >= 120
        ? AppColors.primary
        : activityMinutes >= 45
        ? AppColors.primaryBorder
        : AppColors.primaryLight;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              fontSize: 11,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : hasActivity
                  ? intensity.withValues(alpha: 0.65)
                  : AppColors.primaryLighter,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: AppTextStyles.small.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textMain,
              ),
            ),
          ),
          const SizedBox(height: 5),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: hasActivity ? 6 : 4,
            height: hasActivity ? 6 : 4,
            decoration: BoxDecoration(
              color: hasActivity ? AppColors.primary : AppColors.greyBorder,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
