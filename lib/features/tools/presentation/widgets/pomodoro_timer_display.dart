import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PomodoroTimerDisplay extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final Color color;
  final String modeLabel;

  const PomodoroTimerDisplay({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.color,
    required this.modeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds == 0
        ? 0.0
        : 1 - (remainingSeconds / totalSeconds);

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          _buildGlow(),
          // Background circle
          _buildBgCircle(),
          // Progress ring
          _buildProgressRing(progress),
          // Time text
          _buildTimeText(),
        ],
      ),
    );
  }

  Widget _buildGlow() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildBgCircle() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRing(double progress) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CustomPaint(
        size: Size.infinite,
        painter: _ProgressRingPainter(progress: progress, color: color),
      ),
    );
  }

  Widget _buildTimeText() {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            modeLabel,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: GoogleFonts.poppins(
            fontSize: 58,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            height: 1,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getTimeLabel(),
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  String _getTimeLabel() {
    if (remainingSeconds == 0) return 'Selesai!';
    if (remainingSeconds == totalSeconds) return 'Siap untuk mulai';
    return 'Tetap fokus...';
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ProgressRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;

    // Background track
    final trackPaint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = SweepGradient(
          colors: [color.withOpacity(0.6), color],
          startAngle: -math.pi / 2,
          endAngle: math.pi * 2,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        progress * 2 * math.pi,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
