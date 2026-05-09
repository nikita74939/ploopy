import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

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
        color: Colors.grey.shade100,
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
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(17),
            border: active
                ? Border.all(color: Colors.grey.shade200, width: 0.5)
                : null,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: active
                ? TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  )
                : TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}