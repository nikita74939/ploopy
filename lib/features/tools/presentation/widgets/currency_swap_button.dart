import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CurrencySwapButton extends StatelessWidget {
  final VoidCallback onTap;

  const CurrencySwapButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.swap_vert_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}