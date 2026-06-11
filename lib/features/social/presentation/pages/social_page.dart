import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart' hide AppColors;
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/bottom_sheet_insets.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../activity/domain/entities/activity_entity.dart';
import '../../../activity/presentation/bloc/activity_bloc.dart';
import '../../../activity/presentation/widgets/activity_composer_sheet.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../event/domain/entities/event_entity.dart';
import '../../../event/presentation/bloc/event_bloc.dart';
import '../../../event/presentation/pages/event_detail_page.dart';
import 'public_profile_page.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String? get _currentUserId {
    final state = context.read<AuthBloc>().state;
    return state is Authenticated ? state.user.userId : null;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ActivityBloc>().add(LoadActivities());
    context.read<EventBloc>().add(LoadEvents());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLighter,
      appBar: AppBar(
        backgroundColor: AppColors.greyLighter,
        title: Text('Social', style: AppTextStyles.title),
        actions: [
          _SocialIconButton(icon: Icons.search_rounded, onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.textMain,
              shape: const CircleBorder(),
              side: const BorderSide(color: AppColors.greyBorder),
            ),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.notification),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.tabActive,
          unselectedLabelStyle: AppTextStyles.tabInactive,
          onTap: (index) {
            if (index == 0) {
              context.read<ActivityBloc>().add(LoadActivities());
            } else {
              context.read<EventBloc>().add(LoadEvents());
            }
          },
          tabs: const [
            Tab(text: 'Activity'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ActivityTab(currentUserId: _currentUserId),
          _EventTab(currentUserId: _currentUserId),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'social_fab',
        onPressed: _showComposer,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showComposer() async {
    final userId = _currentUserId;
    if (userId == null) return;
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ActivityBloc>(),
        child: ActivityComposerSheet(userId: userId),
      ),
    );
    if (created == true && mounted) {
      context.read<ActivityBloc>().add(LoadActivities());
    }
  }
}

class _SocialIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textMain,
        shape: const CircleBorder(),
        side: const BorderSide(color: AppColors.greyBorder),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Activity Tab
// ─────────────────────────────────────────

class _ActivityTab extends StatelessWidget {
  final String? currentUserId;

  const _ActivityTab({this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityBloc, ActivityState>(
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
          if (state.activities.isEmpty) {
            return _buildEmptyState(
              icon: Icons.article_outlined,
              label: 'No activities yet',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppStyle.paddingMedium),
            itemCount: state.activities.length,
            itemBuilder: (context, index) => _ActivityCard(
              activity: state.activities[index],
              currentUserId: currentUserId,
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ─────────────────────────────────────────
// Activity Card — gaya FeedPostCard
// ─────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final ActivityEntity activity;
  final String? currentUserId;

  const _ActivityCard({required this.activity, this.currentUserId});

  Color get _authorColor {
    const colors = [
      Color(0xFF6C63FF),
      Color(0xFF43B89C),
      Color(0xFFFF6584),
      Color(0xFFFFB347),
      Color(0xFF4FC3F7),
      Color(0xFFBA68C8),
    ];
    final name = activity.userName ?? '';
    final index = name.isEmpty ? 0 : name.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  String get _dateLabel {
    final diff = DateTime.now().difference(activity.createdAt);
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
              _buildLeftColumn(context),
              const SizedBox(width: 14),
              Expanded(child: _buildRightContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    return Column(
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _openPublicProfile(context),
          child: _buildAvatar(),
        ),
        const SizedBox(height: 10),
        _buildDateChip(),
      ],
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
              InkWell(
                onTap: () => _openPublicProfile(context),
                child: Text(
                  activity.userName ?? 'Unknown',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
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
                onTap: () => context.read<ActivityBloc>().add(
                  DeleteActivity(id: activity.id),
                ),
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

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          icon: activity.isLikedByMe ? Icons.favorite : Icons.favorite_border,
          label: '${activity.likeCount}',
          color: activity.isLikedByMe ? AppColors.error : Colors.grey.shade500,
          onTap: () {
            if (currentUserId == null) return;
            context.read<ActivityBloc>().add(
              ToggleLike(activityId: activity.id, userId: currentUserId!),
            );
          },
        ),
        const SizedBox(width: 20),
        _ActionButton(
          icon: Icons.mode_comment_outlined,
          label: '${activity.commentCount}',
          color: Colors.grey.shade500,
          onTap: () => _showComments(context),
        ),
      ],
    );
  }

  void _showComments(BuildContext context) {
    context.read<ActivityBloc>().add(LoadComments(activityId: activity.id));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      builder: (ctx) => BlocProvider.value(
        value: context.read<ActivityBloc>(),
        child: _CommentsSheet(
          activityId: activity.id,
          currentUserId: currentUserId ?? '',
        ),
      ),
    );
  }

  void _openPublicProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicProfilePage(userId: activity.userId),
      ),
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
    if (text.isEmpty || widget.currentUserId.isEmpty) return;
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

// ─────────────────────────────────────────
// Event Tab
// ─────────────────────────────────────────

class _EventTab extends StatelessWidget {
  final String? currentUserId;

  const _EventTab({this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state is EventOperationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is EventLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is EventsLoaded) {
          if (state.events.isEmpty) {
            return _buildEmptyState(
              icon: Icons.event_outlined,
              label: 'No events yet',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppStyle.paddingMedium),
            itemCount: state.events.length,
            itemBuilder: (context, index) => _EventCard(
              event: state.events[index],
              currentUserId: currentUserId,
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventEntity event;
  final String? currentUserId;

  const _EventCard({required this.event, this.currentUserId});

  Color get _accentColor {
    try {
      final hex = event.color.replaceAll('#', '').replaceAll('0x', '');
      return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  IconData get _icon {
    switch (event.icon) {
      case 'conference':
        return Icons.groups;
      case 'workshop':
        return Icons.build;
      case 'seminar':
        return Icons.school;
      case 'meetup':
        return Icons.people;
      case 'sports':
        return Icons.sports;
      case 'music':
        return Icons.music_note;
      case 'food':
        return Icons.restaurant;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;
    final userId = currentUserId;
    final isCreator = userId == event.creatorId;
    final canJoin = !event.isJoinedByMe && !event.isFull && event.isUpcoming;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
          ),
          child: Ink(
            padding: const EdgeInsets.all(AppStyle.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.greyBorder),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_icon, color: accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.name,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 13,
                                color: AppColors.greyText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateTimeUtils.formatDateTime(event.eventDate),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.greyText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Price badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: event.isFree
                            ? AppColors.success.withValues(alpha: 0.15)
                            : accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: event.isFree ? AppColors.success : accent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        event.isFree
                            ? 'FREE'
                            : NumberFormat.currency(
                                locale: 'id_ID',
                                symbol: 'Rp',
                                decimalDigits: 0,
                              ).format(event.price),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: event.isFree ? AppColors.success : accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Meta
                Row(
                  children: [
                    Icon(
                      event.isOnline ? Icons.videocam : Icons.location_on,
                      size: 15,
                      color: AppColors.greyText,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.isOnline ? 'Online' : (event.location ?? 'TBD'),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.greyText,
                        ),
                      ),
                    ),
                    if (event.maxParticipants != null &&
                        event.maxParticipants! > 0) ...[
                      Icon(Icons.people, size: 15, color: AppColors.greyText),
                      const SizedBox(width: 4),
                      Text(
                        '${event.currentParticipants}/${event.maxParticipants}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: event.isFull
                              ? AppColors.error
                              : AppColors.greyText,
                          fontWeight: event.isFull
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (event.isFull) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'FULL',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
                if (event.description != null &&
                    event.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    event.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Footer
                Row(
                  children: [
                    if (event.creatorName != null) ...[
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: accent.withValues(alpha: 0.2),
                        child: event.creatorPhoto != null
                            ? ClipOval(
                                child: Image.network(
                                  event.creatorPhoto!,
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Text(
                                event.creatorName![0].toUpperCase(),
                                style: TextStyle(fontSize: 10, color: accent),
                              ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        event.creatorName!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (isCreator)
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accent,
                          side: BorderSide(color: accent),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Edit'),
                      )
                    else if (event.isJoinedByMe)
                      OutlinedButton(
                        onPressed: () {
                          if (userId == null) return;
                          context.read<EventBloc>().add(
                            LeaveEvent(eventId: event.id, userId: userId),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Leave'),
                      )
                    else
                      ElevatedButton(
                        onPressed: canJoin
                            ? () {
                                if (userId == null) return;
                                context.read<EventBloc>().add(
                                  JoinEvent(eventId: event.id, userId: userId),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          canJoin
                              ? 'Join'
                              : (!event.isUpcoming ? 'Ended' : 'Full'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Shared helper
// ─────────────────────────────────────────

Widget _buildEmptyState({required IconData icon, required String label}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: AppColors.greyText.withValues(alpha: 0.5)),
        const SizedBox(height: 16),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 18, color: AppColors.greyText),
        ),
      ],
    ),
  );
}
