import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum SocialTab { activity, event }

class SocialTabBar extends StatelessWidget {
  final SocialTab selected;
  final ValueChanged<SocialTab> onChanged;

  const SocialTabBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              tab: SocialTab.activity,
              label: 'Aktivitas',
              icon: Icons.notes_rounded,
            ),
          ),
          Expanded(
            child: _buildTab(
              tab: SocialTab.event,
              label: 'Event',
              icon: Icons.calendar_today_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required SocialTab tab,
    required String label,
    required IconData icon,
  }) {
    final isSelected = selected == tab;

    return GestureDetector(
      onTap: () => onChanged(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? AppColors.black : AppColors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: (isSelected
                      ? AppTextStyles.tabActive
                      : AppTextStyles.tabInactive)
                  .copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
