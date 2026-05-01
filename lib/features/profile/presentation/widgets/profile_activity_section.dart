import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../social/domain/activity_model.dart';
import '../../../social/presentation/widgets/social_activity_tab.dart';

class ProfileActivitySection extends StatelessWidget {
  final VoidCallback? onCreatePost;
  final Function(Activity)? onTapPost;

  const ProfileActivitySection({
    super.key,
    this.onCreatePost,
    this.onTapPost,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktivitas',
          style: GoogleFonts.robotoMono(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        SocialActivityTab(
          onCreatePost: onCreatePost ?? () {},
          onTapPost: onTapPost ?? (_) {},
        ),
      ],
    );
  }
}