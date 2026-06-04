import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../data/models/notification_model.dart';
import '../bloc/notification_bloc.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<NotificationBloc>().add(LoadNotifications());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Notifications', style: AppTextStyles.title),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is! NotificationLoaded || state.unreadCount == 0) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () => context.read<NotificationBloc>().add(
                  MarkAllNotificationsAsRead(),
                ),
                child: Text('Mark all read', style: AppTextStyles.link),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              height: 42,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(13),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: AppColors.transparent,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.tabActive.copyWith(
                  color: AppColors.white,
                ),
                unselectedLabelStyle: AppTextStyles.tabInactive,
                tabs: [
                  BlocBuilder<NotificationBloc, NotificationState>(
                    builder: (context, state) {
                      final count = state is NotificationLoaded
                          ? state.unreadCount
                          : 0;
                      return Tab(text: count > 0 ? 'All ($count)' : 'All');
                    },
                  ),
                  const Tab(text: 'Unread'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return _EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat notifikasi',
              subtitle: state.message,
            );
          }

          if (state is NotificationLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _NotificationList(notifications: state.allNotifications),
                _NotificationList(notifications: state.unreadNotifications),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final List<NotificationModel> notifications;

  const _NotificationList({required this.notifications});

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const _EmptyState(
        icon: Icons.notifications_off_rounded,
        title: 'No notifications',
        subtitle: 'Semua sudah rapi untuk sekarang.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _NotificationCard(notification: notification);
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final tagColor = _tagColor(notification.tag);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.white),
      ),
      onDismissed: (_) => context.read<NotificationBloc>().add(
        DeleteNotification(id: notification.id),
      ),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => context.read<NotificationBloc>().add(
            MarkNotificationAsRead(id: notification.id),
          ),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(AppStyle.paddingMedium),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: notification.isRead
                    ? AppColors.greyBorder
                    : AppColors.primaryBorder,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tagColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_tagIcon(notification.tag), color: tagColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.w800,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notification.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _TagPill(label: notification.tag, color: tagColor),
                          const Spacer(),
                          Text(
                            DateTimeUtils.formatRelative(
                              notification.createdAt,
                            ),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case 'social':
      case 'friend_request':
      case 'friend_accepted':
        return AppColors.blueAccent;
      case 'study':
        return AppColors.success;
      case 'task':
        return AppColors.warning;
      case 'schedule':
        return AppColors.purpleAccent;
      default:
        return AppColors.primary;
    }
  }

  IconData _tagIcon(String tag) {
    switch (tag) {
      case 'social':
      case 'friend_request':
      case 'friend_accepted':
        return Icons.people_alt_rounded;
      case 'study':
        return Icons.school_rounded;
      case 'task':
        return Icons.assignment_rounded;
      case 'schedule':
        return Icons.event_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  final Color color;

  const _TagPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label.replaceAll('_', ' ').toUpperCase(),
        style: AppTextStyles.small.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.title),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
