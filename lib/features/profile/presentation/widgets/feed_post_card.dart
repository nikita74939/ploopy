import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class FeedPostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final bool showAuthorName;

  const FeedPostCard({
    super.key,
    required this.post,
    this.showAuthorName = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAuthorName) _buildAuthorHeader(),
          if (showAuthorName) const SizedBox(height: 10),
          _buildContent(),
          if ((post['images'] as List).isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildImageGrid(post['images'] as List),
          ],
          const SizedBox(height: 10),
          // Footer: date + achievements
          Row(
            children: [
              Text(
                post['date'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.greyHint,
                ),
              ),
              const Spacer(),
              ...(post['achievements'] as List).take(3).map((a) {
                final ach = a as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      ach['icon'] as String,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorHeader() {
    final authorName = post['authorName'] as String;
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            authorName.substring(0, 1).toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          authorName,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          post['date'] as String,
          style: GoogleFonts.poppins(fontSize: 10, color: AppColors.greyHint),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      post['content'] as String,
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: AppColors.black,
        height: 1.5,
      ),
    );
  }

  Widget _buildImageGrid(List images) {
    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildImage(images[0] as String, double.infinity, 160),
      );
    }
    return Row(
      children:
          images.take(3).map((img) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: img == images.last ? 0 : 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _buildImage(img as String, double.infinity, null),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildImage(String url, double? width, double? height) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.greyLight,
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
          ),
        );
      },
      errorBuilder:
          (_, __, ___) => Container(
            color: AppColors.greyLight,
            child: const Icon(
              Icons.broken_image_outlined,
              color: AppColors.greyHint,
              size: 22,
            ),
          ),
    );
  }
}
