import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'feed_post_card.dart';

class ProfileActivitySection extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  final VoidCallback? onCreatePost;
  final VoidCallback? onSeeAll;

  const ProfileActivitySection({
    super.key,
    required this.activities,
    this.onCreatePost,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildCreatePostBox(),
        const SizedBox(height: 14),
        ...activities.map((post) => FeedPostCard(post: post)).toList(),
        if (activities.isNotEmpty) _buildSeeAll(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text('📝', style: GoogleFonts.poppins(fontSize: 15)),
        const SizedBox(width: 6),
        Text(
          'Aktivitas',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${activities.length}',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreatePostBox() {
    return GestureDetector(
      onTap: onCreatePost,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.edit_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ceritakan hari ini, yuk! ✨',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            Icon(
              Icons.photo_library_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.emoji_emotions_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeeAll() {
    return Center(
      child: TextButton(
        onPressed: onSeeAll,
        child: Text(
          'Lihat semua aktivitas',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}