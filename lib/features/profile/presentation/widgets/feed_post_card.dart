import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedPostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final bool showAuthorName; // ⭐ NEW

  const FeedPostCard({
    super.key,
    required this.post,
    this.showAuthorName = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLeftColumn(),
              const SizedBox(width: 14),
              Expanded(child: _buildRightContent()),
            ],
          ),
        ),
      ),
    );
  }

  // ======= LEFT: Author Avatar + Date =======
  Widget _buildLeftColumn() {
    return Column(
      children: [
        _buildAuthorAvatar(),
        const SizedBox(height: 10),
        _buildDateChip(),
      ],
    );
  }

  Widget _buildAuthorAvatar() {
    final authorColor = post['authorColor'] as Color;
    final authorAvatar = post['authorAvatar'] as String;
    final authorName = post['authorName'] as String;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: authorColor.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: authorColor.withOpacity(0.3), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        authorAvatar.isNotEmpty
            ? authorAvatar.substring(0, 1).toUpperCase()
            : authorName.substring(0, 1).toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: authorColor,
        ),
      ),
    );
  }

  Widget _buildDateChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        post['date'] as String,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  // ======= RIGHT CONTENT =======
  Widget _buildRightContent() {
    final achievements = post['achievements'] as List;
    final images = post['images'] as List;
    final info = post['info'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showAuthorName) _buildAuthorHeader(),
        if (showAuthorName) const SizedBox(height: 10),
        if (achievements.isNotEmpty) _buildAchievementBadges(achievements),
        if (achievements.isNotEmpty) const SizedBox(height: 12),
        _buildContent(),
        if (images.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildImageGrid(images),
        ],
        if (info.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildInfoBox(info),
        ],
      ],
    );
  }

  Widget _buildAuthorHeader() {
    return Row(
      children: [
        Text(
          post['authorName'] as String,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          post['fullDate'] as String? ?? post['date'] as String,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadges(List achievements) {
    return Row(
      children: achievements.take(5).map((a) {
        final achievement = a as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: achievement['color'] as Color,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              achievement['icon'] as String,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContent() {
    return Text(
      post['content'] as String,
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.black87,
        height: 1.4,
      ),
    );
  }

  Widget _buildImageGrid(List images) {
    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildImage(images[0] as String, double.infinity, 180),
      );
    }

    return Row(
      children: images.take(3).map((img) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: img == images.last ? 0 : 6,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
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
          color: Colors.grey.shade100,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade100,
        child: Icon(
          Icons.broken_image_rounded,
          color: Colors.grey.shade400,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildInfoBox(List info) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: info.map((i) {
          final item = i as Map<String, dynamic>;
          return Padding(
            padding: EdgeInsets.only(bottom: item == info.last ? 0 : 6),
            child: Row(
              children: [
                Text(
                  item['icon'] as String,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                Text(
                  item['text'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}