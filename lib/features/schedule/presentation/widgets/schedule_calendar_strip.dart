import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';

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
  late PageController _pageController;
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
    // Auto-navigate week saat selectedDate berubah dari luar (misal tombol "Hari ini")
    final newWeekStart = _getWeekStart(widget.selectedDate);
    if (newWeekStart != _currentWeekStart) {
      final diff = newWeekStart.difference(_currentWeekStart).inDays ~/ 7;
      _currentWeekStart = newWeekStart;
      _pageController.animateToPage(
        _pageController.page!.round() + diff,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  DateTime _getWeekStart(DateTime date) {
    // Senin sebagai awal minggu
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // ── Month + Year Header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
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
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _NavButton(
                      icon: Icons.chevron_left,
                      onTap: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _NavButton(
                      icon: Icons.chevron_right,
                      onTap: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── Day Header (Mon-Sun) ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 4),
          // ── Week PageView ────────────────────────────────────────────
          SizedBox(
            height: 68,
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
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildWeekRow(DateTime weekStart) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: List.generate(7, (i) {
          final day = weekStart.add(Duration(days: i));
          final isSelected = _isSameDay(day, widget.selectedDate);
          final isToday = _isSameDay(day, DateTime.now());
          final hasEvent = widget.scheduleDates.any((d) => _isSameDay(d, day));

          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onDateSelected(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.textMain
                      : isToday
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? null
                      : isToday
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day.day.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : isToday
                            ? AppColors.primary
                            : AppColors.textMain,
                      ),
                    ),
                    // Event dot
                    if (hasEvent)
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Colors.white70
                              : AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showMonthPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      widget.onDateSelected(picked);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
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
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 2),
          color: Colors.white,
        ),
        child: Icon(icon, size: 18, color: AppColors.textMain),
      ),
    );
  }
}
