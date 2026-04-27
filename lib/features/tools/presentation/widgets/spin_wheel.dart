import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpinWheel extends StatelessWidget {
  final List<String> choices;
  final double rotation; // dalam radian
  final List<Color> colors;

  const SpinWheel({
    super.key,
    required this.choices,
    required this.rotation,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          _buildGlow(),
          // Wheel (rotating)
          Transform.rotate(
            angle: rotation,
            child: _buildWheel(),
          ),
          // Center decoration
          _buildCenterButton(),
          // Pointer (arrow) di atas — static
          _buildPointer(),
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
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildWheel() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CustomPaint(
        size: Size.infinite,
        painter: _WheelPainter(choices: choices, colors: colors),
      ),
    );
  }

  Widget _buildCenterButton() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF8C42), Color(0xFFFF6B42)],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.star_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildPointer() {
    return Positioned(
      top: 0,
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red.shade400, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.arrow_drop_down_rounded,
              color: Colors.red.shade400,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<String> choices;
  final List<Color> colors;

  _WheelPainter({required this.choices, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sectionAngle = (2 * math.pi) / choices.length;

    for (var i = 0; i < choices.length; i++) {
      final startAngle = -math.pi / 2 + (i * sectionAngle);
      final color = colors[i % colors.length];

      // Draw section
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        paint,
      );

      // Draw border between sections
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        borderPaint,
      );

      // Draw text
      _drawText(
        canvas,
        choices[i],
        center,
        radius,
        startAngle + sectionAngle / 2,
      );
    }

    // Outer border
    final outerBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, outerBorder);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double radius,
    double angle,
  ) {
    final textRadius = radius * 0.65;
    final x = center.dx + math.cos(angle) * textRadius;
    final y = center.dy + math.sin(angle) * textRadius;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle + math.pi / 2);

    // Truncate text kalau terlalu panjang
    final displayText = text.length > 12 ? '${text.substring(0, 10)}...' : text;

    final textPainter = TextPainter(
      text: TextSpan(
        text: displayText,
        style: GoogleFonts.poppins(
          fontSize: choices.length > 6 ? 11 : 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_WheelPainter oldDelegate) {
    return oldDelegate.choices != choices;
  }
}