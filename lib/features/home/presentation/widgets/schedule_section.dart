import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'schedule_timeline_item.dart';

class ScheduleSection extends StatefulWidget {
  final List<Map<String, dynamic>> scheduleItems;
  final List<Map<String, dynamic>> taskItems;
  final VoidCallback? onSeeAllSchedule;
  final VoidCallback? onSeeAllTask;

  const ScheduleSection({
    super.key,
    required this.scheduleItems,
    required this.taskItems,
    this.onSeeAllSchedule,
    this.onSeeAllTask,
  });

  @override
  State<ScheduleSection> createState() => _ScheduleSectionState();
}

class _ScheduleSectionState extends State<ScheduleSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTabBar(),
        const SizedBox(height: 14),
        _tabController.index == 0
            ? _buildScheduleList()
            : _buildTaskList(),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade500,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Jadwal'),
          Tab(text: 'Tugas'),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    final items = widget.scheduleItems;
    if (items.isEmpty) {
      return _buildEmpty('Tidak ada jadwal hari ini');
    }
    return Column(
      children: [
        ...List.generate(items.length, (i) => ScheduleTimelineItem(
          item: items[i],
          isLast: i == items.length - 1,
        )),
        const SizedBox(height: 4),
        _buildSeeAllButton(
          label: 'Lihat semua jadwal',
          onTap: widget.onSeeAllSchedule,
        ),
      ],
    );
  }

  Widget _buildTaskList() {
    final items = widget.taskItems;
    if (items.isEmpty) {
      return _buildEmpty('Tidak ada tugas hari ini');
    }
    return Column(
      children: [
        ...List.generate(items.length, (i) => _buildTaskItem(items[i])),
        const SizedBox(height: 4),
        _buildSeeAllButton(
          label: 'Lihat semua tugas',
          onTap: widget.onSeeAllTask,
        ),
      ],
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> item) {
    final isDone = item['done'] as bool? ?? false;
    final color = item['color'] as Color? ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Row(
        children: [
          // Checkbox style dot
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isDone ? color : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDone ? color : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: isDone
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item['icon'] as IconData? ?? Icons.task_alt_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String? ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDone ? Colors.grey.shade400 : Colors.black87,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                if ((item['subject'] as String? ?? '').isNotEmpty)
                  Text(
                    item['subject'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
              ],
            ),
          ),
          // Due date
          if ((item['due'] as String? ?? '').isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item['due'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSeeAllButton({
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.black87),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 32, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}