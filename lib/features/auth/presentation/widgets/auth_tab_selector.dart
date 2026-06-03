import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthTabSelector extends StatelessWidget {
  final bool isLoginSelected;
  final ValueChanged<bool> onTabChanged;

  const AuthTabSelector({
    super.key,
    required this.isLoginSelected,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _tabItem('Masuk', isLoginSelected, () => onTabChanged(true)),
          _tabItem('Daftar', !isLoginSelected, () => onTabChanged(false)),
        ],
      ),
    );
  }

  Widget _tabItem(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? AppColors.surface : AppColors.transparent,
            borderRadius: BorderRadius.circular(17),
            border: active
                ? Border.all(color: AppColors.greyBorder, width: 0.5)
                : null,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: active ? AppTextStyles.tabActive : AppTextStyles.tabInactive,
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
