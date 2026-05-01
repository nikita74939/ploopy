// File: /home/presentation/pages/calendar_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ploopy/core/constants/schedule_dummy_data.dart';
import 'package:ploopy/core/theme/app_colors.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  // Simulated activity data (same as profile heatmap)
  final Map<int, int> _studyMinutes = {
    1: 45, 2: 0, 3: 90, 4: 120, 5: 60, 6: 30, 7: 0,
    8: 150, 9: 90, 10: 60, 11: 0, 12: 45, 13: 120,
    14: 180, 15: 90, 16: 60, 17: 30, 18: 0, 19: 90,
    20: 120, 21: 150, 22: 60, 23: 45, 24: 0, 25: 90,
    26: 120, 27: 180, 28: 90, 29: 60, 30: 45, 31: 0,
  };

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _selectedDate = DateTime.now();
  }

  void _previousMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  Color _getHeatmapColor(int day) {
    final minutes = _studyMinutes[day] ?? 0;
    if (minutes == 0) return AppColors.greyLight;
    if (minutes < 60) return const Color(0xFFD4D4D8);
    if (minutes < 120) return const Color(0xFF71717A);
    if (minutes < 180) return const Color(0xFF3F3F46);
    return AppColors.black;
  }

  bool _hasActivity(int day) {
    return (_studyMinutes[day] ?? 0) > 0;
  }

  List<Map<String, dynamic>> _getSchedulesForDate(DateTime date) {
    // In real app, filter by date
    return ScheduleDummyData.todayItems;
  }

  List<Map<String, dynamic>> _getTasksForDate(DateTime date) {
    return ScheduleDummyData.todayTasks.where((task) {
      return (task['done'] as bool? ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildMonthSelector(),
            const SizedBox(height: 16),
            _buildWeekdayHeader(),
            _buildCalendarGrid(),
            const SizedBox(height: 16),
            _buildHeatmapLegend(),
            const Divider(height: 1, color: Color(0xFFE4E4E7)),
            Expanded(child: _buildSelectedDateContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            color: AppColors.black,
          ),
          Expanded(
            child: Text(
              'Kalender',
              style: GoogleFonts.robotoMono(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _previousMonth,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.black,
                size: 20,
              ),
            ),
          ),
          Text(
            '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
            style: GoogleFonts.robotoMono(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          GestureDetector(
            onTap: _nextMonth,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.black,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: GoogleFonts.robotoMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyText,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startingWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    final daysInMonth = lastDayOfMonth.day;
    final totalCells = startingWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(rows, (rowIndex) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: List.generate(7, (colIndex) {
                final cellIndex = rowIndex * 7 + colIndex;
                final dayNumber = cellIndex - startingWeekday + 1;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 44));
                }

                final isToday = _isToday(dayNumber);
                final isSelected = _isSelected(dayNumber);
                final hasActivity = _hasActivity(dayNumber);

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedDate = DateTime(
                          _currentMonth.year,
                          _currentMonth.month,
                          dayNumber,
                        );
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 44,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.black
                                : isToday
                                ? AppColors.primaryLight
                                : _getHeatmapColor(dayNumber),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isToday && !isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '$dayNumber',
                            style: GoogleFonts.robotoMono(
                              fontSize: 12,
                              fontWeight:
                                  isSelected || isToday
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : _getTextColor(dayNumber),
                            ),
                          ),
                          if (hasActivity && !isSelected)
                            Positioned(
                              bottom: 4,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
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
        }),
      ),
    );
  }

  Widget _buildHeatmapLegend() {
    final levels = [
      (color: AppColors.greyLight, label: '0'),
      (color: const Color(0xFFD4D4D8), label: '<1j'),
      (color: const Color(0xFF71717A), label: '1-2j'),
      (color: const Color(0xFF3F3F46), label: '2-3j'),
      (color: AppColors.black, label: '>3j'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            'Aktivitas: ',
            style: GoogleFonts.robotoMono(fontSize: 9, color: AppColors.greyHint),
          ),
          ...levels.map(
            (l) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: l.color,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: AppColors.greyBorder, width: 0.5),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    l.label,
                    style: GoogleFonts.robotoMono(fontSize: 9, color: AppColors.greyHint),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateContent() {
    if (_selectedDate == null) {
      return Center(
        child: Text(
          'Pilih tanggal untuk melihat jadwal',
          style: GoogleFonts.robotoMono(fontSize: 13, color: AppColors.greyHint),
        ),
      );
    }

    final schedules = _getSchedulesForDate(_selectedDate!);
    final tasks = _getTasksForDate(_selectedDate!);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected date header
          Text(
            _formatSelectedDate(_selectedDate!),
            style: GoogleFonts.robotoMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Schedules section
          _buildContentSection(
            title: 'Jadwal',
            icon: Icons.calendar_today_rounded,
            items: schedules,
            isEmpty: schedules.isEmpty,
            emptyMessage: 'Tidak ada jadwal',
          ),

          if (schedules.isNotEmpty) ...[
            const SizedBox(height: 20),
            ...schedules.map((schedule) => _buildScheduleItem(schedule)),
          ],

          const SizedBox(height: 24),

          // Completed tasks section
          _buildContentSection(
            title: 'Tugas Selesai',
            icon: Icons.task_alt_rounded,
            items: tasks,
            isEmpty: tasks.isEmpty,
            emptyMessage: 'Tidak ada tugas selesai',
          ),

          if (tasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...tasks.map((task) => _buildTaskItem(task)),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildContentSection({
    required String title,
    required IconData icon,
    required List items,
    required bool isEmpty,
    required String emptyMessage,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.robotoMono(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${items.length}',
            style: GoogleFonts.robotoMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItem(Map<String, dynamic> item) {
    final color = item['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item['icon'] as IconData, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  style: GoogleFonts.robotoMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 11, color: AppColors.greyText),
                    const SizedBox(width: 4),
                    Text(
                      '${item['time']} • ${item['duration']}',
                      style: GoogleFonts.robotoMono(
                        fontSize: 11,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.greyLighter,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item['time'] as String,
              style: GoogleFonts.robotoMono(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    final color = task['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.greyLighter,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task['title'] as String,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
                decoration: TextDecoration.lineThrough,
                decorationColor: AppColors.greyHint,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(task['icon'] as IconData, color: color, size: 12),
                const SizedBox(width: 4),
                Text(
                  task['subject'] as String,
                  style: GoogleFonts.robotoMono(
                    fontSize: 10,
                    color: AppColors.greyText
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(int day) {
    final now = DateTime.now();
    return _currentMonth.month == now.month &&
        _currentMonth.year == now.year &&
        day == now.day;
  }

  bool _isSelected(int day) {
    if (_selectedDate == null) return false;
    return _currentMonth.month == _selectedDate!.month &&
        _currentMonth.year == _selectedDate!.year &&
        day == _selectedDate!.day;
  }

  Color _getTextColor(int day) {
    final minutes = _studyMinutes[day] ?? 0;
    if (minutes >= 120) return Colors.white;
    return AppColors.black;
  }

  String _monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[month];
  }

  String _formatSelectedDate(DateTime date) {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month]} ${date.year}';
  }
}