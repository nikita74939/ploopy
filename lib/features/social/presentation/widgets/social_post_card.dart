import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialPostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const SocialPostCard({super.key, required this.post});

  @override
  State<SocialPostCard> createState() => _SocialPostCardState();
}

class _SocialPostCardState extends State<SocialPostCard> {
  late bool _liked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _liked = widget.post['liked'] as bool;
    _likeCount = widget.post['likes'] as int;
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = widget.post['location'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [if (hasLocation) _buildLocationHeader(), _buildCard()],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 14, bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            size: 13,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 4),
          Text(
            widget.post['location'] as String,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
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
            widget.post['distance'] as String,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
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
    );
  }

  // ======= LEFT: Avatar + Date =======
  Widget _buildLeftColumn() {
    return Column(
      children: [_buildAvatar(), const SizedBox(height: 10), _buildDateChip()],
    );
  }

  Widget _buildAvatar() {
    final color = widget.post['authorColor'] as Color;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.post['authorAvatar'] as String,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: color,
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
        widget.post['date'] as String,
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
    final achievements = widget.post['achievements'] as List;
    final images = widget.post['images'] as List;
    final info = widget.post['info'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAuthorHeader(),
        const SizedBox(height: 10),
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
        const SizedBox(height: 12),
        _buildActions(),
      ],
    );
  }

  Widget _buildAuthorHeader() {
    return Row(
      children: [
        Flexible(
          child: Text(
            widget.post['authorName'] as String,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const Spacer(),
        Icon(Icons.more_horiz_rounded, size: 18, color: Colors.grey.shade400),
      ],
    );
  }

  Widget _buildAchievementBadges(List achievements) {
    return Row(
      children:
          achievements.take(5).map((a) {
            final item = a as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: item['color'] as Color,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  item['icon'] as String,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildContent() {
    return Text(
      widget.post['content'] as String,
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
      children:
          images.take(3).map((img) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: img == images.last ? 0 : 6),
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
      errorBuilder:
          (_, __, ___) => Container(
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
        children:
            info.map((i) {
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

  // ======= INLINE ACTIONS (Like + Comment) =======
  Widget _buildActions() {
    return Row(
      children: [
        _buildActionButton(
          icon: _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          count: _likeCount,
          color: _liked ? Colors.red.shade400 : Colors.grey.shade600,
          onTap: _toggleLike,
        ),
        const SizedBox(width: 20),
        _buildActionButton(
          icon: Icons.mode_comment_outlined,
          count: widget.post['comments'] as int,
          color: Colors.grey.shade600,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 5),
          Text(
            _formatCount(count),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
