import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
        child: isFlipped || isMatched ? _buildFront() : _buildBack(),
      ),
    );
  }

  // Tampilan saat kartu terbuka
  Widget _buildFront() {
    return Container(
      key: const ValueKey(true),
      decoration: BoxDecoration(
        color: isMatched ? const Color(0xFFE8F5E9) : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMatched ? Colors.green.withOpacity(0.5) : AppColors.greyBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  // Tampilan saat kartu tertutup (Aesthetic White-Orange)
  Widget _buildBack() {
    return Container(
      key: const ValueKey(false),
      decoration: BoxDecoration(
        color: AppColors.primaryLight, // Warna krem oranye sangat lembut[cite: 6]
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3), // Border oranye tipis[cite: 7]
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome_rounded, // Icon yang lebih estetik
          color: AppColors.primary.withOpacity(0.6),
          size: 28,
        ),
      ),
    );
  }
}