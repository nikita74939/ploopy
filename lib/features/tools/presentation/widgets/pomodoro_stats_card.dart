import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PomodoroStatsCard extends StatelessWidget {
  final int completedSessions;
  final int totalFocusMinutes;

  const PomodoroStatsCard({
    super.key,
    required this.completedSessions,
    required this.totalFocusMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStat(
              icon: Icons.check_circle_rounded,
              value: completedSessions.toString(),
              label: 'Sesi selesai',
              color: const Color(0xFFFF6B6B),
            ),
          ),
          Container(width: 1, height: 36, color: Colors.grey.shade100),
          Expanded(
            child: _buildStat(
              icon: Icons.timer_rounded,
              value: _formatMinutes(totalFocusMinutes),
              label: 'Total fokus',
              color: const Color(0xFF4D96FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }
}
