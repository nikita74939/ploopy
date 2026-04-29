import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_helper.dart';

class MiniCalendar extends StatelessWidget {
  final int selectedDay;
  final ValueChanged<int> onDaySelected;
  final VoidCallback? onOpenCalendar;

  const MiniCalendar({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    this.onOpenCalendar,
  });

  @override
  Widget build(BuildContext context) {
    final weekDates = DateHelper.getCurrentWeekDates();
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month + calendar button header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateHelper.formatMonthYear(now), // e.g. "April 2025"
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black87,
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
                      'Kalender',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Week day row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final d = weekDates[i];
            final isSelected = d.day == selectedDay;
            return _buildDayItem(
              label: DateHelper.dayNames[i],
              day: d.day,
              isSelected: isSelected,
              onTap: () => onDaySelected(d.day),
            );
          }),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              'Kalender lengkap segera hadir! 🗓️',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ],
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildDayItem({
    required String label,
    required int day,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? Colors.black87 : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}