import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';

class ScheduleCalendarStrip extends StatefulWidget {
  final DateTime selectedDate;
  final Set<DateTime> scheduleDates;
  final void Function(DateTime) onDateSelected;

  const ScheduleCalendarStrip({
    super.key,
    required this.selectedDate,
    required this.scheduleDates,
    required this.onDateSelected,
  });

  @override
  State<ScheduleCalendarStrip> createState() => _ScheduleCalendarStripState();
}

class _ScheduleCalendarStripState extends State<ScheduleCalendarStrip> {
  late final PageController _pageController;
  late DateTime _currentWeekStart;
  static const int _totalPages = 400;
  static const int _initialPage = 200;

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getWeekStart(widget.selectedDate);
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void didUpdateWidget(ScheduleCalendarStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newWeekStart = _getWeekStart(widget.selectedDate);
    if (!_isSameDay(newWeekStart, _currentWeekStart)) {
      final diff = newWeekStart.difference(_currentWeekStart).inDays ~/ 7;
      _currentWeekStart = newWeekStart;
      _pageController.animateToPage(
        _pageController.page!.round() + diff,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
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
                GestureDetector(
                  onTap: () => _showMonthPicker(context),
                  child: Row(
                    children: [
                      Text(
                        DateFormat(
                          'MMMM yyyy',
                          'id_ID',
                        ).format(_currentWeekStart),
                        style: AppTextStyles.title.copyWith(fontSize: 13),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _NavButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _NavButton(
                      icon: Icons.chevron_right_rounded,
                      onTap: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 74,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  final diff = page - _initialPage;
                  setState(() {
                    _currentWeekStart = _getWeekStart(
                      DateTime.now().add(Duration(days: diff * 7)),
                    );
                  });
                },
                itemCount: _totalPages,
                itemBuilder: (context, page) {
                  final diff = page - _initialPage;
                  final weekStart = _getWeekStart(
                    DateTime.now().add(Duration(days: diff * 7)),
                  );
                  return _buildWeekRow(weekStart);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekRow(DateTime weekStart) {
    const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = weekStart.add(Duration(days: i));
        final isSelected = _isSameDay(day, widget.selectedDate);
        final isToday = _isSameDay(day, DateTime.now());
        final hasSchedule = widget.scheduleDates.any((d) => _isSameDay(d, day));

        return GestureDetector(
          onTap: () => widget.onDateSelected(day),
          child: SizedBox(
            width: 38,
            height: 72,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  labels[i],
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
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                        ? AppColors.primaryLight.withValues(alpha: 0.65)
                        : AppColors.primaryLighter,
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.primaryBorder)
                        : null,
                  ),
                  child: Text(
                    '${day.day}',
                    style: AppTextStyles.small.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.white : AppColors.textMain,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: hasSchedule ? 6 : 4,
                  height: hasSchedule ? 6 : 4,
                  decoration: BoxDecoration(
                    color: hasSchedule
                        ? AppColors.primary
                        : AppColors.greyBorder,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  DateTime _getWeekStart(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: date.weekday - 1));
  }

  Future<void> _showMonthPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) widget.onDateSelected(picked);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.primary,
        ),
        child: Icon(icon, size: 18, color: AppColors.white),
      ),
    );
  }
}
