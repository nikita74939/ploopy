import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';

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
        _buildHeader(),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) =>
                _AchievementBadge(achievement: achievements[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('🏆', style: GoogleFonts.poppins(fontSize: 15)),
            const SizedBox(width: 6),
            Text(
              'Achievement',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'Lihat semua',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
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
    final color = achievement['color'] as Color;
    final unlocked = achievement['unlocked'] as bool;
    final badgeAsset = achievement['badgeAsset'] as String;

    return Container(
      width: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked ? color.withValues(alpha: 0.3) : Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: unlocked
                  ? color.withValues(alpha: 0.15)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: unlocked ? 1 : 0.28,
                  child: ColorFiltered(
                    colorFilter: unlocked
                        ? const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.dst,
                          )
                        : const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.saturation,
                          ),
                    child: Image.asset(
                      badgeAsset,
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.emoji_events_rounded,
                        color: unlocked ? color : Colors.grey.shade400,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                if (!unlocked)
                  Icon(
                    Icons.lock_rounded,
                    color: Colors.grey.shade500,
                    size: 18,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            achievement['title'] as String,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: unlocked ? Colors.black87 : Colors.grey.shade400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            achievement['desc'] as String,
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: Colors.grey.shade400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
