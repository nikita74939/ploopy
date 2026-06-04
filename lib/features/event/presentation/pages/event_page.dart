import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../data/models/event_model.dart';
import '../bloc/event_bloc.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String? get _currentUserId => Supabase.instance.client.auth.currentUser?.id;

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
        title: Text('Events', style: AppTextStyles.title),
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
                onTap: (index) {
                  context.read<EventBloc>().add(
                    index == 0 ? LoadEvents() : LoadUpcomingEvents(),
                  );
                },
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
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EventsLoaded) {
            if (state.events.isEmpty) {
              return const _EmptyEvents();
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 96),
              itemCount: state.events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) => _EventCard(
                event: state.events[index],
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

class _EventCard extends StatelessWidget {
  final EventModel event;
  final String? currentUserId;

  const _EventCard({required this.event, this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final accent = _parseColor(event.color);
    final userId = currentUserId;
    final isCreator = userId == event.creatorId;
    final canJoin = !event.isJoinedByMe && !event.isFull && event.isUpcoming;

    return Container(
      padding: const EdgeInsets.all(AppStyle.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_iconFromName(event.icon), color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 5),
                    _MetaLine(
                      icon: Icons.calendar_today_rounded,
                      label: DateTimeUtils.formatDateTime(event.eventDate),
                    ),
                  ],
                ),
              ),
              _PricePill(event: event, color: accent),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoPill(
                  icon: event.isOnline
                      ? Icons.videocam_rounded
                      : Icons.location_on_rounded,
                  label: event.isOnline ? 'Online' : (event.location ?? 'TBD'),
                ),
              ),
              if (event.maxParticipants != null &&
                  event.maxParticipants! > 0) ...[
                const SizedBox(width: 8),
                _InfoPill(
                  icon: Icons.people_alt_rounded,
                  label:
                      '${event.currentParticipants}/${event.maxParticipants}',
                  isWarning: event.isFull,
                ),
              ],
            ],
          ),
          if (event.description?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              event.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall,
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              if (event.creatorName != null)
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: accent.withValues(alpha: 0.14),
                        backgroundImage: event.creatorPhoto != null
                            ? NetworkImage(event.creatorPhoto!)
                            : null,
                        child: event.creatorPhoto == null
                            ? Text(
                                event.creatorName![0].toUpperCase(),
                                style: AppTextStyles.small.copyWith(
                                  color: accent,
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
                )
              else
                const Spacer(),
              if (isCreator)
                _ActionButton(label: 'Edit', color: accent, onTap: () {})
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
    );
  }

  Color _parseColor(String value) {
    try {
      final hex = value.replaceAll('#', '').replaceAll('0x', '');
      return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
    } catch (_) {
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

class _PricePill extends StatelessWidget {
  final EventModel event;
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: pillColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(14),
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
      height: 38,
      child: outlined
          ? OutlinedButton(
              onPressed: disabled ? null : onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: effectiveColor,
                side: BorderSide(color: effectiveColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(label),
            )
          : ElevatedButton(
              onPressed: disabled ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: effectiveColor,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(label),
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
