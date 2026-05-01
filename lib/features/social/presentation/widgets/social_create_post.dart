import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SocialCreatePost extends StatelessWidget {
  final VoidCallback onTap;

  const SocialCreatePost({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.greyBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.greyBorder),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Bagikan progres belajarmu...',
                  style: AppTextStyles.body.copyWith(color: AppColors.grey),
                ),
              ),
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 20,
                color: AppColors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
