// lib/features/study_desk/presentation/widgets/study_schedule_section.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class StudyScheduleSection extends StatefulWidget {
  final List<Map<String, dynamic>> scheduleItems;
  final List<Map<String, dynamic>> taskItems;
  final VoidCallback? onSeeAllSchedule;
  final VoidCallback? onSeeAllTask;

  const StudyScheduleSection({
    super.key,
    required this.scheduleItems,
    required this.taskItems,
    this.onSeeAllSchedule,
    this.onSeeAllTask,
  });

  @override
  State<StudyScheduleSection> createState() => _StudyScheduleSectionState();
}

class _StudyScheduleSectionState extends State<StudyScheduleSection>
    with SingleTickerProviderStateMixin {
  bool _showSchedule = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _switchTab(bool showSchedule) {
    if (_showSchedule == showSchedule) return;
    HapticFeedback.selectionClick();
    _animController.reverse().then((_) {
      if (!mounted) return;
      setState(() => _showSchedule = showSchedule);
      _animController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _showSchedule ? widget.scheduleItems : widget.taskItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with segmented toggle
        _buildHeader(),
        const SizedBox(height: 14),

        // Content with fade animation
        FadeTransition(
          opacity: _fadeAnim,
          child:
              items.isEmpty
                  ? _buildEmpty()
                  : _showSchedule
                  ? _buildScheduleList()
                  : _buildTaskList(),
        ),

        const SizedBox(height: 4),

        // See all button
        _buildSeeAll(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Align(
              key: ValueKey(_showSchedule),
              alignment: Alignment.centerLeft,
              child: Text(
                _showSchedule ? 'Jadwal Hari Ini' : 'Tugas',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
        ),
        _buildSegmentedToggle(),
      ],
    );
  }

  Widget _buildSegmentedToggle() {
    return Container(
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.greyLighter,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segmentBtn(
            icon: Icons.calendar_today_rounded,
            label: 'Jadwal',
            active: _showSchedule,
            onTap: () => _switchTab(true),
          ),
          _segmentBtn(
            icon: Icons.task_alt_rounded,
            label: 'Tugas',
            active: !_showSchedule,
            onTap: () => _switchTab(false),
          ),
        ],
      ),
    );
  }

  Widget _segmentBtn({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow:
              active
                  ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: active ? AppColors.black : AppColors.greyHint,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? AppColors.black : AppColors.greyHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    return Column(
      children: List.generate(widget.scheduleItems.length, (i) {
        return _buildScheduleItem(
          widget.scheduleItems[i],
          i == widget.scheduleItems.length - 1,
        );
      }),
    );
  }

  Widget _buildScheduleItem(Map<String, dynamic> item, bool isLast) {
    final color = item['color'] as Color;
    final isDone = item['done'] as bool? ?? false;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Text(
                  item['time'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 1.5,
                      color: isLast ? Colors.transparent : AppColors.greyBorder,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dot
          Column(
            children: [
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.primary : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone ? AppColors.primary : AppColors.greyBorder,
                    width: 1.5,
                  ),
                ),
                child:
                    isDone
                        ? const Icon(Icons.check, size: 11, color: Colors.white)
                        : null,
              ),
            ],
          ),

          const SizedBox(width: 10),

          // Card
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDone ? AppColors.greyLighter : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.greyBorder),
              ),
              child: Row(
                children: [
                  // Icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color:
                          isDone
                              ? AppColors.greyLight
                              : color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: isDone ? AppColors.greyHint : color,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color:
                                isDone ? AppColors.greyHint : AppColors.black,
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 11,
                              color: AppColors.greyHint,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              item['duration'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.greyHint,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return Column(
      children: widget.taskItems.map((task) => _buildTaskItem(task)).toList(),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    final bool done = task['done'] ?? false;
    final Color itemColor = task['color'] as Color;
    final String due = task['due'] ?? '';

    Color dueColor;
    Color dueBg;
    if (done) {
      dueColor = AppColors.greyHint;
      dueBg = AppColors.greyLighter;
    } else if (due == 'Kemarin') {
      dueColor = AppColors.black;
      dueBg = AppColors.greyLight;
    } else if (due == 'Besok') {
      dueColor = AppColors.greyText;
      dueBg = AppColors.greyLighter;
    } else {
      dueColor = AppColors.primary;
      dueBg = AppColors.primaryLight;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => task['done'] = !done);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: done ? AppColors.greyLighter : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.greyBorder),
        ),
        child: Row(
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: done ? itemColor : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: done ? itemColor : AppColors.greyBorder,
                  width: 1.5,
                ),
              ),
              child:
                  done
                      ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      )
                      : null,
            ),
            const SizedBox(width: 10),
            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    done
                        ? AppColors.greyLight
                        : itemColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                task['icon'] as IconData,
                color: done ? AppColors.greyHint : itemColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['title'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: done ? AppColors.greyHint : AppColors.black,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if ((task['subject'] as String? ?? '').isNotEmpty)
                    Text(
                      task['subject'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.greyText,
                      ),
                    ),
                ],
              ),
            ),
            // Due badge
            if (due.isNotEmpty)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: dueBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  due,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: dueColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeeAll() {
    return GestureDetector(
      onTap: _showSchedule ? widget.onSeeAllSchedule : widget.onSeeAllTask,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.greyBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lihat semua',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 28, color: AppColors.greyBorder),
          const SizedBox(height: 8),
          Text(
            _showSchedule ? 'Tidak ada jadwal' : 'Tidak ada tugas',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.greyHint),
          ),
        ],
      ),
    );
  }
}
