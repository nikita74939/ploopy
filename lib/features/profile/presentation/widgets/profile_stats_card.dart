import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card statistik profil. Data berasal dari ProfileLoaded:
///   totalFriends    = friends.length
///   totalActivities = userAchievements.length (atau feed posts nanti)
///   currentStreak   = streak.currentStreak
class ProfileStatsCard extends StatelessWidget {
  final int totalFriends;
  final int totalActivities;
  final int currentStreak;

  const ProfileStatsCard({
    super.key,
    required this.totalFriends,
    required this.totalActivities,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.group_rounded,
              value: totalFriends.toString(),
              label: 'Teman',
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _StatItem(
              icon: Icons.edit_note_rounded,
              value: totalActivities.toString(),
              label: 'Aktivitas',
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _StatItem(
              icon: Icons.local_fire_department_rounded,
              value: currentStreak.toString(),
              label: 'Streak',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      Container(width: 1, height: 36, color: Colors.grey.shade100);
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFFF8C42)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
