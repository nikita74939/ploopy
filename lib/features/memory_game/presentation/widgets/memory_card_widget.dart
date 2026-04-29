import 'dart:math';
import 'package:flutter/material.dart';

class MemoryCardWidget extends StatelessWidget {
  final String emoji;
  final bool isFlipped;
  final bool isMatched;
  final VoidCallback onTap;

  const MemoryCardWidget({
    super.key,
    required this.emoji,
    required this.isFlipped,
    required this.isMatched,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isMatched ? null : onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          final rotate = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              final isUnder = ValueKey(false) == child?.key;
              final tilt = isUnder ? min(rotate.value, pi / 2) : rotate.value;
              return Transform(
                transform: Matrix4.rotationY(tilt),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        child: isFlipped || isMatched
            ? _buildFront()
            : _buildBack(),
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      key: const ValueKey(true),
      decoration: BoxDecoration(
        color: isMatched
            ? const Color(0xFF4CAF82)
            : const Color(0xFF2D6A9F),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isMatched
                ? const Color(0xFF4CAF82).withOpacity(0.4)
                : const Color(0xFF2D6A9F).withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 36),
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      key: const ValueKey(false),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2F4E), Color(0xFF0F1E33)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF2D6A9F).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.psychology_rounded,
          color: const Color(0xFF2D6A9F).withOpacity(0.7),
          size: 32,
        ),
      ),
    );
  }
}
