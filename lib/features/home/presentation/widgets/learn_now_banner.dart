import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ploopy_mascot.dart';

class LearnNowBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const LearnNowBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.creamDeep,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryBorder),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(child: _buildContent()),
            const SizedBox(width: 12),
            const PloopyMascot(size: 86, withBook: false),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Daily Plan',
          style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Ploopy bantu susun jadwal.\nMulai dari tugas terdekat.',
          style: AppTextStyles.small.copyWith(height: 1.45),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            'See Plan',
            style: AppTextStyles.buttonPrimary.copyWith(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
