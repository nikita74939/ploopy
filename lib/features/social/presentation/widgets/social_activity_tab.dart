import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ploopy/features/social/domain/activity_model.dart';
import 'package:ploopy/features/social/presentation/widgets/social_create_post.dart';
import 'package:ploopy/shared/services/activity_service.dart';
import '../../../../core/theme/app_colors.dart';

class SocialActivityTab extends StatelessWidget {
  final VoidCallback onCreatePost;
  final Function(Activity) onTapPost;

  const SocialActivityTab({
    super.key,
    required this.onCreatePost,
    required this.onTapPost,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Activity>>(
      future: ActivityService.getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final activities = snapshot.data ?? [];

        if (activities.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh logic
          },
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: activities.length + 1, // +1 for create button
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              if (i == 0) {
                return SocialCreatePost(onTap: onCreatePost);
              }
              return _ActivityCard(
                activity: activities[i - 1],
                onTap: () => onTapPost(activities[i - 1]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📭', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 14),
            Text(
              'Belum ada aktivitas',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Jadilah yang pertama\nmemulai percakapan!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.activity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              _buildContent(),
              const SizedBox(height: 12),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.primaries[activity.userId.hashCode % Colors.primaries.length],
                Colors.primaries[
                    (activity.userId.hashCode + 1) % Colors.primaries.length],
              ],
            ),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            activity.userName.isNotEmpty ? activity.userName[0].toUpperCase() : '👤',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.userName,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (activity.location != null) ...[
                    Icon(
                      Icons.location_on_rounded,
                      size: 11,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        activity.location!,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Icon(
                    Icons.schedule_rounded,
                    size: 10,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _formatTime(activity.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.more_vert_rounded,
            color: Colors.grey.shade400,
            size: 18,
          ),
          onPressed: () {},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activity.content.isNotEmpty)
          Text(
            activity.content,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        if (activity.imageUrl != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 160,
              width: double.infinity,
              color: Colors.grey.shade100,
              child: const Center(
                child: Icon(
                  Icons.image_rounded,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _buildActionButton(
          icon: activity.isLiked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          label: '${activity.likeCount}',
          color: activity.isLiked ? Colors.red : Colors.grey.shade600,
          onTap: () {},
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: '${activity.commentCount}',
          color: Colors.grey.shade600,
          onTap: () {},
        ),
        const Spacer(),
        _buildActionButton(
          icon: Icons.share_outlined,
          label: 'Share',
          color: Colors.grey.shade600,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}j';
    if (diff.inDays < 7) return '${diff.inDays}h';
    return '${time.day}/${time.month}';
  }
}