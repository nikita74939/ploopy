import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class GameStatsBar extends StatelessWidget {
  final int moves;
  final int matches;
  final int totalPairs;
  final int seconds;

  const GameStatsBar({
    super.key,
    required this.moves,
    required this.matches,
    required this.totalPairs,
    required this.seconds,
  });

  String get _formattedTime {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Moves', value: '$moves', color: Colors.blueAccent),
              _StatItem(label: 'Matched', value: '$matches/$totalPairs', color: Colors.green),
              _StatItem(label: 'Time', value: _formattedTime, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: totalPairs > 0 ? matches / totalPairs : 0,
              backgroundColor: AppColors.greyLight,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.heading.copyWith(color: color, fontSize: 18)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}