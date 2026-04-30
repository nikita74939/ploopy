import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ActionPostCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ActionPostCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final content = data['content'] as String? ?? '';
    final achievements = (data['achievements'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPreviewPost(content, achievements),
        const SizedBox(height: 10),
        _buildMetadata(achievements),
      ],
    );
  }

  Widget _buildPreviewPost(String content, List achievements) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.greyLighter,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.greyBorder),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person_outline,
              size: 20,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (achievements.isNotEmpty) ...[
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children:
                        achievements.take(5).map<Widget>((a) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.greyBorder),
                            ),
                            child: Text(
                              a.toString(),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  content,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.black,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(List achievements) {
    return Row(
      children: [
        const Icon(Icons.public_outlined, size: 12, color: AppColors.grey),
        const SizedBox(width: 4),
        Text('Akan di-post ke feed kamu', style: AppTextStyles.caption),
        const Spacer(),
        if (achievements.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: Text(
              '${achievements.length} achievement',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
