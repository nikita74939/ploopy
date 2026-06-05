import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/bottom_sheet_insets.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/activity_entity.dart';
import '../bloc/activity_bloc.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String? get _currentUserId {
    final state = context.read<AuthBloc>().state;
    return state is Authenticated ? state.user.userId : null;
  }

  @override
  void initState() {
    super.initState();
    context.read<ActivityBloc>().add(LoadActivities());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Activity',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocBuilder<ActivityBloc, ActivityState>(
        builder: (context, state) {
          if (state is ActivityLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ActivityError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ActivityBloc>().add(LoadActivities()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ActivitiesLoaded) {
            if (state.activities.isEmpty) return _buildEmptyState();
            return _buildActivityList(state.activities);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No activities yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(List<ActivityEntity> activities) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppStyle.paddingMedium),
      itemCount: activities.length,
      itemBuilder: (context, index) => _ActivityCard(
        activity: activities[index],
        currentUserId: _currentUserId,
        onLike: (activity) {
          final userId = _currentUserId;
          if (userId == null) return;
          context.read<ActivityBloc>().add(
            ToggleLike(activityId: activity.id, userId: userId),
          );
        },
        onComment: (activity) => _showComments(activity.id),
        onDelete: (activity) =>
            context.read<ActivityBloc>().add(DeleteActivity(id: activity.id)),
      ),
    );
  }

  void _showComments(String activityId) {
    context.read<ActivityBloc>().add(LoadComments(activityId: activityId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (ctx) => BlocProvider.value(
        value: context.read<ActivityBloc>(),
        child: _CommentsSheet(
          activityId: activityId,
          currentUserId: _currentUserId ?? '',
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Activity Card — gaya FeedPostCard
// ─────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final ActivityEntity activity;
  final String? currentUserId;
  final void Function(ActivityEntity) onLike;
  final void Function(ActivityEntity) onComment;
  final void Function(ActivityEntity) onDelete;

  const _ActivityCard({
    required this.activity,
    required this.currentUserId,
    required this.onLike,
    required this.onComment,
    required this.onDelete,
  });

  // Hasilkan warna konsisten berdasarkan nama user
  Color get _authorColor {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF43B89C),
      const Color(0xFFFF6584),
      const Color(0xFFFFB347),
      const Color(0xFF4FC3F7),
      const Color(0xFFBA68C8),
    ];
    final name = activity.userName ?? '';
    final index = name.isEmpty ? 0 : name.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  String get _dateLabel {
    final dt = activity.createdAt;
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  String get _fullDate => DateTimeUtils.formatRelative(activity.createdAt);

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
              Expanded(child: _buildRightContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Kiri: Avatar + chip tanggal ──
  Widget _buildLeftColumn() {
    return Column(
      children: [_buildAvatar(), const SizedBox(height: 10), _buildDateChip()],
    );
  }

  Widget _buildAvatar() {
    final color = _authorColor;
    final initial = (activity.userName ?? '?')[0].toUpperCase();

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      alignment: Alignment.center,
      child: activity.userPhoto != null
          ? ClipOval(
              child: Image.network(
                activity.userPhoto!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Text(
                  initial,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            )
          : Text(
              initial,
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
        _dateLabel,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  // ── Kanan: Konten utama ──
  Widget _buildRightContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAuthorHeader(context),
        const SizedBox(height: 10),
        if (activity.achievementId != null) ...[
          _buildAchievementBadge(),
          const SizedBox(height: 12),
        ],
        _buildText(),
        if (activity.imageUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildImageGrid(activity.imageUrls),
        ],
        if (activity.location != null) ...[
          const SizedBox(height: 12),
          _buildInfoBox(),
        ],
        const SizedBox(height: 12),
        _buildActions(context),
      ],
    );
  }

  Widget _buildAuthorHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                activity.userName ?? 'Unknown',
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
                _fullDate,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton(
          padding: EdgeInsets.zero,
          icon: Icon(Icons.more_horiz, color: Colors.grey.shade400, size: 20),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Report'),
                ],
              ),
            ),
            if (currentUserId == activity.userId)
              PopupMenuItem(
                value: 'delete',
                onTap: () => onDelete(activity),
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB347).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFB347).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFFFB347),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.emoji_events_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Achievement Unlocked!',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE08000),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildText() {
    return Text(
      activity.text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.black87,
        height: 1.4,
      ),
    );
  }

  Widget _buildImageGrid(List<String> urls) {
    if (urls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildNetworkImage(urls[0], double.infinity, 180),
      );
    }

    return Row(
      children: urls.take(3).map((url) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: url == urls.last ? 0 : 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1,
                child: _buildNetworkImage(url, double.infinity, null),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNetworkImage(String url, double? width, double? height) {
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

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            size: 14,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 8),
          Text(
            activity.location!,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          icon: activity.isLikedByMe ? Icons.favorite : Icons.favorite_border,
          label: '${activity.likeCount}',
          color: activity.isLikedByMe ? AppColors.error : Colors.grey.shade500,
          onTap: () => onLike(activity),
        ),
        const SizedBox(width: 20),
        _ActionButton(
          icon: Icons.mode_comment_outlined,
          label: '${activity.commentCount}',
          color: Colors.grey.shade500,
          onTap: () => onComment(activity),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Comments Bottom Sheet
// ─────────────────────────────────────────

class _CommentsSheet extends StatefulWidget {
  final String activityId;
  final String currentUserId;

  const _CommentsSheet({required this.activityId, required this.currentUserId});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ActivityBloc>().add(
      AddComment(
        activityId: widget.activityId,
        userId: widget.currentUserId,
        content: text,
      ),
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: EdgeInsets.only(
          bottom: BottomSheetInsets.bottom(context, spacing: 0),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Comments',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(),
            Expanded(
              child: BlocBuilder<ActivityBloc, ActivityState>(
                builder: (context, state) {
                  if (state is CommentsLoaded) {
                    if (state.comments.isEmpty) {
                      return Center(
                        child: Text(
                          'No comments yet',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: state.comments.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemBuilder: (context, index) {
                        final comment = state.comments[index];
                        final initial = (comment.userName ?? '?')[0]
                            .toUpperCase();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  initial,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            comment.userName ?? 'Unknown',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            DateTimeUtils.formatRelative(
                                              comment.createdAt,
                                            ),
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        comment.content,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.black87,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  if (state is ActivityLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.poppins(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _submit,
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
