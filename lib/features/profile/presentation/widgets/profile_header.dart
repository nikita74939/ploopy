import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? bio;
  final String? avatarUrl;
  final int joinYear;
  final VoidCallback onEditPressed;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.bio,
    this.avatarUrl,
    required this.joinYear,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 28),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              _buildAvatar(),
              Positioned(bottom: 0, right: 0, child: _buildEditBadge()),
            ],
          ),
          const SizedBox(height: 14),
          Text(name, style: AppTextStyles.heading),
          const SizedBox(height: 2),
          Text(
            email,
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
          if (bio?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(
              bio!.trim(),
              style: AppTextStyles.small,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          _buildJoinBadge(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: avatarUrl != null && avatarUrl!.trim().isNotEmpty
          ? ClipOval(
              child: Image.network(
                avatarUrl!,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            )
          : Text(
              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
              style: AppTextStyles.display.copyWith(
                fontSize: 36,
                color: AppColors.primary,
              ),
            ),
    );
  }

  Widget _buildEditBadge() {
    return GestureDetector(
      onTap: onEditPressed,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 2.5),
        ),
        child: const Icon(Icons.edit_rounded, size: 14, color: AppColors.white),
      ),
    );
  }

  Widget _buildJoinBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 12,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            'Bergabung $joinYear',
            style: AppTextStyles.small.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
