import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ScheduleTimelineItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isLast;
  final VoidCallback? onTap; // ← TAMBAH INI

  const ScheduleTimelineItem({
    super.key,
    required this.item,
    required this.isLast,
    this.onTap, // ← TAMBAH INI
  });

  @override
  State<ScheduleTimelineItem> createState() => _ScheduleTimelineItemState();
}

class _ScheduleTimelineItemState extends State<ScheduleTimelineItem> {
  late _ScheduleStatus _status;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _status = _getStatus();
    _syncDoneValue();
    _scheduleStatusRefresh();
  }

  @override
  void didUpdateWidget(covariant ScheduleTimelineItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      _status = _getStatus();
      _syncDoneValue();
      _scheduleStatusRefresh();
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  bool get _isDone => _status == _ScheduleStatus.done;
  bool get _isOngoing => _status == _ScheduleStatus.ongoing;

  _ScheduleStatus _getStatus() {
    final start = _startTime;
    final duration = _durationMinutes;
    if (start == null || duration == null) {
      return (widget.item['done'] as bool? ?? false)
          ? _ScheduleStatus.done
          : _ScheduleStatus.upcoming;
    }

    final now = DateTime.now();
    final end = start.add(Duration(minutes: duration));
    if (now.isBefore(start)) return _ScheduleStatus.upcoming;
    if (now.isBefore(end)) return _ScheduleStatus.ongoing;
    return _ScheduleStatus.done;
  }

  DateTime? get _startTime {
    final rawTime = widget.item['time'] as String?;
    if (rawTime == null) return null;

    final match = RegExp(r'^(\d{1,2})[.:](\d{2})$').firstMatch(rawTime);
    if (match == null) return null;

    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) return null;

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  int? get _durationMinutes {
    final durationNum = widget.item['durationNum'];
    if (durationNum is int) return durationNum;

    final durationText = widget.item['duration'] as String?;
    if (durationText == null) return null;

    final match = RegExp(r'\d+').firstMatch(durationText);
    return match == null ? null : int.tryParse(match.group(0)!);
  }

  void _syncDoneValue() {
    widget.item['done'] = _status == _ScheduleStatus.done;
  }

  void _scheduleStatusRefresh() {
    _statusTimer?.cancel();

    final start = _startTime;
    final duration = _durationMinutes;
    if (start == null || duration == null) return;

    final now = DateTime.now();
    final end = start.add(Duration(minutes: duration));
    DateTime? nextChange;

    if (now.isBefore(start)) {
      nextChange = start;
    } else if (now.isBefore(end)) {
      nextChange = end;
    }

    if (nextChange == null) return;

    _statusTimer = Timer(nextChange.difference(now), () {
      if (!mounted) return;
      setState(() {
        _status = _getStatus();
        _syncDoneValue();
      });
      _scheduleStatusRefresh();
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
            style: GoogleFonts.robotoMono(
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
                color:
                    widget.isLast ? Colors.transparent : AppColors.greyBorder,
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child:
              _isOngoing
                  ? CustomPaint(
                    key: const ValueKey('ongoing'),
                    size: const Size(20, 20),
                    painter: _DashedCirclePainter(color: AppColors.black),
                  )
                  : AnimatedContainer(
                    key: ValueKey(_isDone),
                    duration: const Duration(milliseconds: 200),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _isDone ? AppColors.primary : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            _isDone ? AppColors.primary : AppColors.greyBorder,
                        width: 1.5,
                      ),
                    ),
                    child:
                        _isDone
                            ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                            : null,
                  ),
        ),
      ],
    );
  }

  Widget _buildCard() {
    final color = widget.item['color'] as Color;
    final location = widget.item['location'] as String? ?? '';

    return GestureDetector(
      onTap: widget.onTap, // ← TAMBAH INI
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _isDone ? AppColors.greyLighter : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.greyBorder, width: 1),
        ),
        child: Row(
          children: [
            _buildIcon(color),
            const SizedBox(width: 12),
            Expanded(child: _buildInfo(location)), // ← UPDATE
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
        color: _isDone ? AppColors.greyLight : color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        widget.item['icon'] as IconData,
        color: _isDone ? Colors.grey.shade400 : color,
        size: 20,
      ),
    );
  }

  Widget _buildInfo(String location) {
    // ← UPDATE PARAMETER
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.robotoMono(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _isDone ? Colors.grey.shade400 : Colors.black87,
            decoration:
                _isDone ? TextDecoration.lineThrough : TextDecoration.none,
            decorationColor: Colors.grey.shade400,
          ),
          child: Text(widget.item['title']),
        ),
        // ── Tampilkan Lokasi ──
        if (location.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 12,
                color: _isDone ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  location,
                  style: GoogleFonts.robotoMono(
                    fontSize: 11,
                    color:
                        _isDone ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
          style: GoogleFonts.robotoMono(
            fontSize: 11,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}

enum _ScheduleStatus { upcoming, ongoing, done }

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.7
          ..strokeCap = StrokeCap.round;

    final rect = Offset.zero & size;
    const dashCount = 9;
    const gapRadians = 0.23;
    final dashRadians = (math.pi * 2 / dashCount) - gapRadians;

    for (var i = 0; i < dashCount; i++) {
      final startAngle = i * math.pi * 2 / dashCount;
      canvas.drawArc(rect.deflate(1), startAngle, dashRadians, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}