import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AiEmptyState extends StatelessWidget {
  const AiEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.greyBorder),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.smart_toy_outlined,
                size: 34,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 20),
            Text('Halo, aku Ploopy AI', style: AppTextStyles.heading),
            const SizedBox(height: 6),
            Text(
              'Tanya seputar belajar, produktivitas,\natau rencana harian kamu.',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
