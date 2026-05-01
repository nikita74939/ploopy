import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileAchievementSection extends StatelessWidget {
  final List<Map<String, dynamic>> achievements;
  final VoidCallback? onSeeAll;

  const ProfileAchievementSection({
    super.key,
    required this.achievements,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievement',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'Lihat semua',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.greyText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder:
                (_, i) => _AchievementBadge(achievement: achievements[i]),
          ),
        ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Map<String, dynamic> achievement;

  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement['unlocked'] as bool;

    return Container(
      width: 80,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.black : AppColors.greyLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            unlocked ? achievement['icon'] as IconData : Icons.lock_rounded,
            color: unlocked ? Colors.white : AppColors.greyHint,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            achievement['title'] as String,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: unlocked ? Colors.white : AppColors.greyHint,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            achievement['desc'] as String,
            style: GoogleFonts.poppins(
              fontSize: 8,
              color:
                  unlocked
                      ? Colors.white.withOpacity(0.6)
                      : AppColors.greyHandle,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
