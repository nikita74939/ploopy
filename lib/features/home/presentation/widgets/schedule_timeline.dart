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
    ).animate(
      CurvedAnimation(parent: _animController!, curve: Curves.easeOutCubic),
    );
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
            child:
                items.isEmpty
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
                      children:
                          items.map((task) => _buildTaskItem(task)).toList(),
                    ),
          ),
        ),
        const SizedBox(height: 4),
        _buildSeeAll(),
      ],
    );
  }

  // ── Header ───────────────────────────────────────
  // Di dalam _buildHeader(), ubah padding atas:
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
                style: GoogleFonts.robotoMono(
                  fontSize: 15,
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

  // ── See All ──────────────────────────────────────
  Widget _buildSeeAll() {
    return GestureDetector(
      onTap: widget.onSeeAll,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.greyBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lihat semua',
              style: GoogleFonts.robotoMono(
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyBorder, width: 1),
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
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: active ? AppColors.black : AppColors.greyHint,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? AppColors.black : AppColors.greyHint,
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        children: [
          Text(
            _showSchedule ? 'Tidak ada jadwal' : 'Tidak ada tugas',
            style: GoogleFonts.robotoMono(
              fontSize: 13,
              color: AppColors.greyHint,
              fontWeight: FontWeight.w600,
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
      dueColor = AppColors.black;
      dueBg = AppColors.greyLight;
    } else if (due == 'Besok') {
      dueColor = AppColors.greyText;
      dueBg = AppColors.greyLighter;
    } else {
      dueColor = AppColors.black;
      dueBg = AppColors.primaryLight;
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
          color: done ? AppColors.greyLighter : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: done ? AppColors.greyBorder : AppColors.greyBorder,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    done
                        ? AppColors.greyLight
                        : itemColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
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
                    style: GoogleFonts.robotoMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: done ? AppColors.greyHint : AppColors.black,
                      decoration:
                          done
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                      decorationColor: Colors.grey.shade400,
                    ),
                    child: Text(task['title'] ?? ''),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task['subject'] ?? '',
                    style: GoogleFonts.robotoMono(
                      fontSize: 11,
                      color: AppColors.greyText,
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
                style: GoogleFonts.robotoMono(
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
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: done ? AppColors.primary : AppColors.greyBorder,
                  width: 1.8,
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
          ],
        ),
      ),
    );
  }
}
