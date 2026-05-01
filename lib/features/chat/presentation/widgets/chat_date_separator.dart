import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ChatDateSeparator extends StatelessWidget {
  final String date;

  const ChatDateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(height: 1, color: AppColors.greyBorder),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: Text(
              date,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
          ),
          Expanded(
            child: Container(height: 1, color: AppColors.greyBorder),
          ),
        ],
      ),
    );
  }
}