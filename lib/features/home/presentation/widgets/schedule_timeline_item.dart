import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ScheduleTimelineItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isLast;

  const ScheduleTimelineItem({
    super.key,
    required this.item,
    required this.isLast,
  });

  @override
  State<ScheduleTimelineItem> createState() => _ScheduleTimelineItemState();
}

class _ScheduleTimelineItemState extends State<ScheduleTimelineItem> {
  late bool _isDone;

  @override
  void initState() {
    super.initState();
    _isDone = widget.item['done'] as bool;
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() {
      _isDone = !_isDone;
      widget.item['done'] = _isDone;
    });
  }

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
            widget.item['time'],
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
                color: widget.isLast
                    ? Colors.transparent
                    : AppColors.greyBorder,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Column(
      children: [
        const SizedBox(height: 2),
        GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _isDone ? AppColors.primary : AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: _isDone ? AppColors.primary : AppColors.primaryBorder,
                width: 1.5,
              ),
            ),
            child: _isDone
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCard() {
    final color = widget.item['color'] as Color;

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _isDone ? AppColors.primaryLighter : AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.greyBorder, width: 1),
        ),
        child: Row(
          children: [
            _buildIcon(color),
            const SizedBox(width: 12),
            Expanded(child: _buildInfo()),
            const SizedBox(width: 8),
            _buildDuration(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: _isDone ? AppColors.greyBorder : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        widget.item['icon'] as IconData,
        color: _isDone ? Colors.grey.shade400 : color,
        size: 20,
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _isDone ? AppColors.textMuted : AppColors.textMain,
            decoration: _isDone
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            decorationColor: Colors.grey.shade400,
          ),
          child: Text(widget.item['title']),
        ),
        if ((widget.item['streak'] as String? ?? '').isNotEmpty)
          Text(
            'Streak ${widget.item['streak']}',
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
          widget.item['duration'],
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400),
        ),
      ],
    );
  }
}
