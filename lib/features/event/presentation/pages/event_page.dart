import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/event_entity.dart';
import '../bloc/event_bloc.dart';
import 'event_detail_page.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String? get _currentUserId {
    final state = context.read<AuthBloc>().state;
    return state is Authenticated ? state.user.userId : null;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Events', style: AppTextStyles.heading),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.greyBorder),
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (index) {
                  context.read<EventBloc>().add(
                    index == 0 ? LoadEvents() : LoadUpcomingEvents(),
                  );
                },
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(9),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: AppColors.transparent,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.tabActive.copyWith(
                  color: AppColors.white,
                ),
                unselectedLabelStyle: AppTextStyles.tabInactive,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Upcoming'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: BlocConsumer<EventBloc, EventState>(
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
            return const _EventSkeleton();
          }

          if (state is EventError) {
            return _EventError(
              message: state.message,
              onRetry: () => context.read<EventBloc>().add(
                _tabController.index == 0 ? LoadEvents() : LoadUpcomingEvents(),
              ),
            );
          }

          if (state is EventsLoaded) {
            if (state.events.isEmpty) {
              return const _EmptyEvents();
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<EventBloc>().add(
                  _tabController.index == 0
                      ? LoadEvents()
                      : LoadUpcomingEvents(),
                );
                await Future<void>.delayed(const Duration(milliseconds: 450));
              },
              child: _EventList(
                events: state.events,
                currentUserId: _currentUserId,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  final List<EventEntity> events;
  final String? currentUserId;

  const _EventList({required this.events, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final upcoming = events.where((event) => event.isUpcoming).length;
    final joined = events.where((event) => event.isJoinedByMe).length;
    final free = events.where((event) => event.isFree).length;
    final nextEvent = _nearestUpcoming(events);

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 96),
      itemCount: events.length + 1,
      separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 16 : 14),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _EventOverview(
            upcomingCount: upcoming,
            joinedCount: joined,
            freeCount: free,
            nextEvent: nextEvent,
          );
        }
        return _EventCard(
          event: events[index - 1],
          currentUserId: currentUserId,
        );
      },
    );
  }

  EventEntity? _nearestUpcoming(List<EventEntity> events) {
    final upcoming = events.where((event) => event.isUpcoming).toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return upcoming.isEmpty ? null : upcoming.first;
  }
}

class _EventOverview extends StatelessWidget {
  final int upcomingCount;
  final int joinedCount;
  final int freeCount;
  final EventEntity? nextEvent;

  const _EventOverview({
    required this.upcomingCount,
    required this.joinedCount,
    required this.freeCount,
    required this.nextEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.textMain,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_activity_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextEvent?.name ?? 'Events',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.white,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      nextEvent == null
                          ? 'Temukan kegiatan belajar dan komunitas.'
                          : DateTimeUtils.formatDateTime(nextEvent!.eventDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Upcoming',
                  value: upcomingCount.toString(),
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: 'Joined',
                  value: joinedCount.toString(),
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: 'Free',
                  value: freeCount.toString(),
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventEntity event;
  final String? currentUserId;

  const _EventCard({required this.event, this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final accent = _themeAccent(event);
    final userId = currentUserId;
    final isCreator = userId == event.creatorId;
    final canJoin = !event.isJoinedByMe && !event.isFull && event.isUpcoming;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
        ),
        child: Ink(
          padding: const EdgeInsets.all(16),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EventIconTile(
                    icon: _iconFromName(event.icon),
                    color: accent,
                    isOnline: event.isOnline,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            _StatusPill(event: event),
                            _PricePill(event: event, color: AppColors.primary),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Text(
                          event.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.heading.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 7),
                        _MetaLine(
                          icon: Icons.calendar_today_rounded,
                          label: DateTimeUtils.formatDateTime(event.eventDate),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (event.description?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: AppColors.greyLighter,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.greyBorder),
                  ),
                  child: Text(
                    event.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(height: 1.45),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoPill(
                    icon: event.isOnline
                        ? Icons.videocam_rounded
                        : Icons.location_on_rounded,
                    label: event.isOnline
                        ? 'Online'
                        : (event.location ?? 'TBD'),
                  ),
                  if (event.maxParticipants != null &&
                      event.maxParticipants! > 0)
                    _InfoPill(
                      icon: Icons.people_alt_rounded,
                      label:
                          '${event.currentParticipants}/${event.maxParticipants}',
                      isWarning: event.isFull,
                    ),
                ],
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: event.creatorName == null
                        ? Text(
                            'Komunitas Ploopy',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )
                        : Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: AppColors.primaryLight,
                                backgroundImage: event.creatorPhoto != null
                                    ? NetworkImage(event.creatorPhoto!)
                                    : null,
                                child: event.creatorPhoto == null
                                    ? Text(
                                        event.creatorName![0].toUpperCase(),
                                        style: AppTextStyles.small.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  event.creatorName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(width: 10),
                  if (isCreator)
                    _ActionButton(
                      label: 'Edit',
                      color: AppColors.primary,
                      onTap: () {},
                    )
                  else if (event.isJoinedByMe)
                    _ActionButton(
                      label: 'Leave',
                      color: AppColors.error,
                      outlined: true,
                      onTap: () {
                        if (userId == null) return;
                        context.read<EventBloc>().add(
                          LeaveEvent(eventId: event.id, userId: userId),
                        );
                      },
                    )
                  else
                    _ActionButton(
                      label: canJoin
                          ? 'Join Now'
                          : (!event.isUpcoming ? 'Ended' : 'Full'),
                      color: AppColors.primary,
                      disabled: !canJoin,
                      onTap: () {
                        if (userId == null || !canJoin) return;
                        context.read<EventBloc>().add(
                          JoinEvent(eventId: event.id, userId: userId),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _themeAccent(EventEntity event) {
    switch (event.icon) {
      case 'workshop':
        return AppColors.tealAccent;
      case 'seminar':
      case 'conference':
      case 'meetup':
        return AppColors.blueAccent;
      case 'sports':
        return AppColors.success;
      case 'music':
        return AppColors.pinkAccent;
      case 'food':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData _iconFromName(String? iconName) {
    switch (iconName) {
      case 'conference':
      case 'meetup':
        return Icons.groups_rounded;
      case 'workshop':
        return Icons.build_rounded;
      case 'seminar':
        return Icons.school_rounded;
      case 'sports':
        return Icons.sports_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      default:
        return Icons.event_rounded;
    }
  }
}

class _EventIconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isOnline;

  const _EventIconTile({
    required this.icon,
    required this.color,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 86,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 9,
            right: 10,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 13,
              color: color.withValues(alpha: 0.72),
            ),
          ),
          Center(child: Icon(icon, color: color, size: 34)),
          Positioned(
            left: 10,
            bottom: 9,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOnline ? Icons.wifi_rounded : Icons.location_on_rounded,
                size: 14,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final EventEntity event;

  const _StatusPill({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = event.isJoinedByMe
        ? AppColors.blueAccent
        : event.isFull
        ? AppColors.error
        : event.isUpcoming
        ? AppColors.success
        : AppColors.textMuted;
    final label = event.isJoinedByMe
        ? 'JOINED'
        : event.isFull
        ? 'FULL'
        : event.isUpcoming
        ? 'OPEN'
        : 'ENDED';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.small.copyWith(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  final EventEntity event;
  final Color color;

  const _PricePill({required this.event, required this.color});

  @override
  Widget build(BuildContext context) {
    final label = event.isFree
        ? 'FREE'
        : NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp',
            decimalDigits: 0,
          ).format(event.price);
    final pillColor = event.isFree ? AppColors.success : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: pillColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.small.copyWith(
          fontSize: 10,
          color: pillColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaLine({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isWarning;

  const _InfoPill({
    required this.icon,
    required this.label,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? AppColors.error : AppColors.textSecondary;
    return Container(
      constraints: const BoxConstraints(minHeight: 38),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;
  final bool disabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.outlined = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = disabled ? AppColors.textMuted : color;
    return SizedBox(
      height: 40,
      child: outlined
          ? OutlinedButton(
              onPressed: disabled ? null : onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: effectiveColor,
                side: BorderSide(color: effectiveColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                label,
                style: AppTextStyles.buttonSecondary.copyWith(
                  color: effectiveColor,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: disabled ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: effectiveColor,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(label, style: AppTextStyles.buttonPrimary),
            ),
    );
  }
}

class _EventSkeleton extends StatelessWidget {
  const _EventSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 96),
      children: [
        _SkeletonBox(height: 150, radius: 8),
        const SizedBox(height: 16),
        for (var i = 0; i < 4; i++) ...[
          _SkeletonBox(height: 178, radius: 8),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double radius;

  const _SkeletonBox({required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.greyBorder),
      ),
    );
  }
}

class _EventError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _EventError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy_rounded,
              size: 58,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text('Gagal memuat event', style: AppTextStyles.title),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text('Coba Lagi', style: AppTextStyles.buttonPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyEvents extends StatelessWidget {
  const _EmptyEvents();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_busy_rounded,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text('No events yet', style: AppTextStyles.title),
          const SizedBox(height: 4),
          Text(
            'Event baru akan muncul di sini.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
