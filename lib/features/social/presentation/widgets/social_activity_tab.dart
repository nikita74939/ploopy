import 'package:flutter/material.dart';
import 'package:ploopy/features/social/domain/activity_model.dart';
import 'package:ploopy/features/social/presentation/widgets/social_create_post.dart';
import 'package:ploopy/shared/services/activity_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

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
          onRefresh: () async {},
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: activities.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
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
            Icon(Icons.forum_outlined, size: 44, color: AppColors.greyHint),
            const SizedBox(height: 14),
            Text(
              'Belum ada aktivitas',
              style: AppTextStyles.heading.copyWith(color: AppColors.black),
            ),
            const SizedBox(height: 4),
            Text(
              'Mulai dari catatan belajar, tugas selesai, atau agenda kampus.',
              textAlign: TextAlign.center,
              style: AppTextStyles.small.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatefulWidget {
  final Activity activity;
  final VoidCallback onTap;

  const _ActivityCard({required this.activity, required this.onTap});

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  late bool _isLiked;
  late int _likeCount;

  Activity get activity => widget.activity;

  @override
  void initState() {
    super.initState();
    _isLiked = activity.isLiked;
    _likeCount = activity.likeCount;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    ActivityService.toggleLike(activity.id);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.greyBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildContent(),
              if (activity.imageUrl != null) ...[
                const SizedBox(height: 12),
                _buildImage(activity.imageUrl!),
              ],
              if (activity.activityTag != null) ...[
                const SizedBox(height: 12),
                _buildActivityTag(activity.activityTag!),
              ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.userName,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _metaText(),
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.more_horiz_rounded, color: AppColors.grey, size: 20),
          onPressed: () {},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = activity.userAvatarUrl;

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitialAvatar(),
        ),
      );
    }

    return _buildInitialAvatar();
  }

  Widget _buildInitialAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.greyBorder),
      ),
      alignment: Alignment.center,
      child: Text(
        activity.userName.isNotEmpty ? activity.userName[0].toUpperCase() : '?',
        style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Text(
      activity.content,
      style: AppTextStyles.body.copyWith(color: AppColors.black, height: 1.45),
    );
  }

  Widget _buildImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              color: AppColors.greyLight,
              alignment: Alignment.center,
              child: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder:
              (_, __, ___) => Container(
                color: AppColors.greyLight,
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.greyHint,
                  size: 28,
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildActivityTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.greyLighter,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 14,
            color: AppColors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _buildActionButton(
          icon:
              _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          label: '$_likeCount',
          isActive: _isLiked,
          onTap: _toggleLike,
        ),
        const SizedBox(width: 18),
        _buildActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: '${activity.commentCount}',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final color = isActive ? AppColors.black : AppColors.grey;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _metaText() {
    final parts = <String>[];
    if (activity.location != null && activity.location!.isNotEmpty) {
      parts.add(activity.location!);
    }
    parts.add(_formatTime(activity.createdAt));
    return parts.join(' · ');
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
