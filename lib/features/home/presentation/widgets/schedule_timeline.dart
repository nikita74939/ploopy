import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'schedule_timeline_item.dart';

class ScheduleTimeline extends StatefulWidget {
  final List<Map<String, dynamic>> scheduleItems;
  final List<Map<String, dynamic>> taskItems;
  final VoidCallback? onSeeAll;

  const ScheduleTimeline({
    super.key,
    required this.scheduleItems,
    required this.taskItems,
    this.onSeeAll,
  });

  @override
  State<ScheduleTimeline> createState() => _ScheduleTimelineState();
}

class _ScheduleTimelineState extends State<ScheduleTimeline>
    with SingleTickerProviderStateMixin {
  bool _showSchedule = true;
  AnimationController? _animController;
  Animation<double>? _fadeAnim;
  Animation<Offset>? _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController!,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController!,
      curve: Curves.easeOutCubic,
    ));
    _animController!.forward();
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  void _switchTab(bool showSchedule) {
    if (_showSchedule == showSchedule) return;
    HapticFeedback.selectionClick();
    _animController?.reverse().then((_) {
      if (!mounted) return;
      setState(() => _showSchedule = showSchedule);
      _animController?.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _showSchedule ? widget.scheduleItems : widget.taskItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        FadeTransition(
          opacity: _fadeAnim ?? const AlwaysStoppedAnimation(1.0),
          child: SlideTransition(
            position: _slideAnim ?? const AlwaysStoppedAnimation(Offset.zero),
            child: items.isEmpty
                ? _buildEmpty()
                : _showSchedule
                    ? Column(
                        children: List.generate(items.length, (i) {
                          return ScheduleTimelineItem(
                            item: items[i],
                            isLast: i == items.length - 1,
                          );
                        }),
                      )
                    : Column(
                        children: items
                            .map((task) => _buildTaskItem(task))
                            .toList(),
                      ),
          ),
        ),
        const SizedBox(height: 4),
        _buildSeeAll(),
      ],
    );
  }

  // ── Header ───────────────────────────────────────
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
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
        _buildSegmentedToggle(),
      ],
    );
  }

  // ── See All ──────────────────────────────────────
  Widget _buildSeeAll() {
    return GestureDetector(
      onTap: widget.onSeeAll,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lihat semua',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_rounded,
              size: 15,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  // ── Segmented Toggle ─────────────────────────────
  Widget _buildSegmentedToggle() {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: active ? Colors.black87 : Colors.grey.shade400,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? Colors.black87 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty ────────────────────────────────────────
  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Text(
            _showSchedule ? '📅' : '✅',
            style: const TextStyle(fontSize: 34),
          ),
          const SizedBox(height: 8),
          Text(
            _showSchedule
                ? 'Tidak ada jadwal hari ini'
                : 'Semua tugas selesai!',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Task Item ────────────────────────────────────
  Widget _buildTaskItem(Map<String, dynamic> task) {
    final bool done = task['done'] ?? false;
    final Color itemColor = task['color'] as Color;
    final String due = task['due'] ?? '';

    Color dueColor;
    Color dueBg;
    if (done) {
      dueColor = Colors.grey.shade400;
      dueBg = Colors.grey.shade100;
    } else if (due == 'Kemarin') {
      dueColor = Colors.red.shade400;
      dueBg = Colors.red.shade50;
    } else if (due == 'Besok') {
      dueColor = Colors.orange.shade700;
      dueBg = Colors.orange.shade50;
    } else {
      dueColor = Colors.green.shade600;
      dueBg = Colors.green.shade50;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => task['done'] = !done);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: done ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: done ? Colors.grey.shade200 : Colors.grey.shade100,
          ),
          boxShadow: done
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: done
                    ? Colors.grey.shade200
                    : itemColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                task['icon'] as IconData,
                color: done ? Colors.grey.shade400 : itemColor,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: done ? Colors.grey.shade400 : Colors.black87,
                      decoration: done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: Colors.grey.shade400,
                    ),
                    child: Text(task['title'] ?? ''),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task['subject'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: done ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: done ? AppColors.primary : Colors.grey.shade300,
                  width: 1.8,
                ),
              ),
              child: done
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}