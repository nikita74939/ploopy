import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F4E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF2D6A9F).withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.touch_app_rounded,
            label: 'Moves',
            value: '$moves',
            color: const Color(0xFF64B5F6),
          ),
          _Divider(),
          _StatItem(
            icon: Icons.star_rounded,
            label: 'Matched',
            value: '$matches/$totalPairs',
            color: const Color(0xFF4CAF82),
          ),
          _Divider(),
          _StatItem(
            icon: Icons.timer_rounded,
            label: 'Time',
            value: _formattedTime,
            color: const Color(0xFFFFB74D),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.1),
    );
  }
}