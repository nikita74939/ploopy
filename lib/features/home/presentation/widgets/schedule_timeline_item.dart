import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ScheduleTimelineItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isLast;

  const ScheduleTimelineItem({
    super.key,
    required this.item,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeColumn(),
          _buildDot(),
          const SizedBox(width: 12),
          Expanded(child: _buildCard()),
        ],
      ),
    );
  }

  Widget _buildTimeColumn() {
    return SizedBox(
      width: 48,
      child: Column(
        children: [
          Text(
            item['time'],
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Center(
              child: Container(
                width: 1.5,
                color: isLast ? Colors.transparent : Colors.grey.shade200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    final isDone = item['done'] as bool;
    return Column(
      children: [
        const SizedBox(height: 2),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isDone ? AppColors.primary : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone ? AppColors.primary : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: isDone
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : null,
        ),
      ],
    );
  }

  Widget _buildCard() {
    final isDone = item['done'] as bool;
    final color = item['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Row(
        children: [
          _buildIcon(color),
          const SizedBox(width: 12),
          Expanded(child: _buildInfo(isDone)),
          const SizedBox(width: 8),
          _buildDuration(),
        ],
      ),
    );
  }

  Widget _buildIcon(Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(item['icon'] as IconData, color: color, size: 20),
    );
  }

  Widget _buildInfo(bool isDone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['title'],
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDone ? Colors.grey.shade400 : Colors.black87,
            decoration: isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        if ((item['streak'] as String).isNotEmpty)
          Text(
            'Streak ${item['streak']}',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade400,
            ),
          ),
      ],
    );
  }

  Widget _buildDuration() {
    return Row(
      children: [
        Icon(Icons.schedule_rounded, size: 13, color: Colors.grey.shade400),
        const SizedBox(width: 3),
        Text(
          item['duration'],
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}