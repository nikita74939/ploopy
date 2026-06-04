import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_helper.dart';

class HomeGreetingHeader extends StatelessWidget {
  final String name;
  final int unreadNotifCount;
  final VoidCallback? onNotifTap;

  const HomeGreetingHeader({
    super.key,
    required this.name,
    this.unreadNotifCount = 0,
    this.onNotifTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateHelper.getGreeting(name),
                style: AppTextStyles.heading.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 2),
              Text(
                DateHelper.formatFullDate(now),
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // ── Bell Button ──────────────────────
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_rounded, size: 22),
              onPressed: onNotifTap,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.textMain,
                shape: const CircleBorder(),
                side: const BorderSide(color: AppColors.greyBorder),
              ),
            ),
            if (unreadNotifCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadNotifCount > 9 ? '9+' : '$unreadNotifCount',
                    style: AppTextStyles.small.copyWith(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
        // ── Avatar ───────────────────────────
        _buildAvatar(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryBorder, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        name.substring(0, 1).toUpperCase(),
        style: AppTextStyles.title.copyWith(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
