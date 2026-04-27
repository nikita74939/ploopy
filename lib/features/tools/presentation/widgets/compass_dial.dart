import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class CompassDial extends StatelessWidget {
  final double heading; // 0-360 derajat

  const CompassDial({super.key, required this.heading});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          _buildOuterGlow(),
          // Compass background
          _buildCompassBg(),
          // Rotating ring (yang muter)
          Transform.rotate(
            angle: -heading * (math.pi / 180),
            child: _buildRotatingDial(),
          ),
          // Static needle (di tengah, tetap arah atas)
          _buildStaticNeedle(),
          // Center dot
          _buildCenterDot(),
        ],
      ),
    );
  }

  Widget _buildOuterGlow() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildCompassBg() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildRotatingDial() {
    return CustomPaint(
      size: Size.infinite,
      painter: _CompassPainter(),
    );
  }

  Widget _buildStaticNeedle() {
    return CustomPaint(
      size: const Size(280, 280),
      painter: _NeedlePainter(),
    );
  }

  Widget _buildCenterDot() {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black87, width: 2),
      ),
    );
  }
}

/// Painter untuk dial compass (angka & huruf arah)
class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    _drawTickMarks(canvas, center, radius);
    _drawCardinalLetters(canvas, center, radius);
    _drawDegreeNumbers(canvas, center, radius);
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius) {
    final paintMajor = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final paintMinor = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 360; i += 5) {
      final isCardinal = i % 90 == 0;
      final isMajor = i % 30 == 0;

      final angle = (i - 90) * (math.pi / 180);
      final tickLength = isCardinal ? 18.0 : (isMajor ? 12.0 : 6.0);

      final outerRadius = radius - 20;
      final innerRadius = outerRadius - tickLength;

      final start = Offset(
        center.dx + math.cos(angle) * innerRadius,
        center.dy + math.sin(angle) * innerRadius,
      );
      final end = Offset(
        center.dx + math.cos(angle) * outerRadius,
        center.dy + math.sin(angle) * outerRadius,
      );

      canvas.drawLine(start, end, isMajor ? paintMajor : paintMinor);
    }
  }

  void _drawCardinalLetters(Canvas canvas, Offset center, double radius) {
    final cardinals = [
      {'letter': 'N', 'angle': 0, 'color': Colors.red.shade400},
      {'letter': 'E', 'angle': 90, 'color': Colors.black87},
      {'letter': 'S', 'angle': 180, 'color': Colors.black87},
      {'letter': 'W', 'angle': 270, 'color': Colors.black87},
    ];

    for (final c in cardinals) {
      final angle = ((c['angle'] as int) - 90) * (math.pi / 180);
      final letterRadius = radius - 52;

      final x = center.dx + math.cos(angle) * letterRadius;
      final y = center.dy + math.sin(angle) * letterRadius;

      final textPainter = TextPainter(
        text: TextSpan(
          text: c['letter'] as String,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: c['color'] as Color,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawDegreeNumbers(Canvas canvas, Offset center, double radius) {
    final degrees = [30, 60, 120, 150, 210, 240, 300, 330];

    for (final deg in degrees) {
      final angle = (deg - 90) * (math.pi / 180);
      final numberRadius = radius - 48;

      final x = center.dx + math.cos(angle) * numberRadius;
      final y = center.dy + math.sin(angle) * numberRadius;

      final textPainter = TextPainter(
        text: TextSpan(
          text: '$deg',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

/// Painter untuk jarum statis (tetap hadap atas)
class _NeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Jarum North (merah, atas)
    final northPaint = Paint()
      ..color = Colors.red.shade500
      ..style = PaintingStyle.fill;

    final northPath = Path()
      ..moveTo(center.dx, center.dy - 80)
      ..lineTo(center.dx - 10, center.dy)
      ..lineTo(center.dx + 10, center.dy)
      ..close();
    canvas.drawPath(northPath, northPaint);

    // Jarum South (abu, bawah)
    final southPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;

    final southPath = Path()
      ..moveTo(center.dx, center.dy + 80)
      ..lineTo(center.dx - 10, center.dy)
      ..lineTo(center.dx + 10, center.dy)
      ..close();
    canvas.drawPath(southPath, southPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}