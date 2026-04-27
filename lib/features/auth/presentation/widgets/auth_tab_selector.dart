import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';

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
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _tabItem('Login', isLoginSelected, () => onTabChanged(true)),
          _tabItem('Register', !isLoginSelected, () => onTabChanged(false)),
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(17),
            border: active
                ? Border.all(color: AppColors.greyBorder, width: 0.5)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: active ? AppTextStyles.tabActive : AppTextStyles.tabInactive,
          ),
        ),
      ),
    );
  }
}