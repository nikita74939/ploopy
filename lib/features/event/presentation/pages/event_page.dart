import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/neo_container.dart';
import '../../../../core/utils/date_utils.dart';
import '../bloc/event_bloc.dart';
import '../../data/models/event_model.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String? get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id;

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
        title: const Text('Events'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            if (index == 0) {
              context.read<EventBloc>().add(LoadEvents());
            } else {
              context.read<EventBloc>().add(LoadUpcomingEvents());
            }
          },
          tabs: const [
            Tab(text: 'All Events'),
            Tab(text: 'Upcoming'),
          ],
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is EventLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EventsLoaded) {
            if (state.events.isEmpty) return _buildEmptyState();
            return _buildEventList(state.events);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create event page
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No events yet',
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(List<EventModel> events) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppStyle.paddingMedium),
      itemCount: events.length,
      itemBuilder: (context, index) => _buildEventCard(events[index]),
    );
  }

  Widget _buildEventCard(EventModel event) {
    final accentColor = _parseColor(event.color);

    return NeoCard(
      accentColor: accentColor,
      onTap: () {
        // TODO: Navigate to event detail
      },
      child: Padding(
        padding: const EdgeInsets.all(AppStyle.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(event, accentColor),
            const SizedBox(height: 12),
            _buildCardMeta(event),
            if (event.description != null && event.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                event.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildCardFooter(event, accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(EventModel event, Color accentColor) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getIconFromName(event.icon), color: accentColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.name,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    DateTimeUtils.formatDateTime(event.eventDate),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Price badge
        _buildPriceBadge(event, accentColor),
      ],
    );
  }

  Widget _buildPriceBadge(EventModel event, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: event.isFree
            ? Colors.green.withOpacity(0.15)
            : accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: event.isFree ? Colors.green : accentColor,
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
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: event.isFree ? Colors.green : accentColor,
        ),
      ),
    );
  }

  Widget _buildCardMeta(EventModel event) {
    return Row(
      children: [
        Icon(
          event.isOnline ? Icons.videocam : Icons.location_on,
          size: 15,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            event.isOnline ? 'Online' : (event.location ?? 'TBD'),
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        if (event.maxParticipants != null && event.maxParticipants! > 0) ...[
          const Icon(Icons.people, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            '${event.currentParticipants}/${event.maxParticipants}',
            style: TextStyle(
              fontSize: 13,
              color: event.isFull ? AppColors.error : AppColors.textSecondary,
              fontWeight:
                  event.isFull ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (event.isFull) ...[
            const SizedBox(width: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'FULL',
                style: TextStyle(
                    fontSize: 10,
                    color: AppColors.error,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildCardFooter(EventModel event, Color accentColor) {
    final userId = _currentUserId;
    final isCreator = userId == event.creatorId;
    final canJoin = !event.isJoinedByMe && !event.isFull && event.isUpcoming;

    return Row(
      children: [
        // Creator info
        if (event.creatorName != null) ...[
          CircleAvatar(
            radius: 12,
            backgroundColor: accentColor.withOpacity(0.2),
            child: event.creatorPhoto != null
                ? ClipOval(
                    child: Image.network(event.creatorPhoto!,
                        width: 24, height: 24, fit: BoxFit.cover))
                : Text(
                    event.creatorName![0].toUpperCase(),
                    style: TextStyle(fontSize: 10, color: accentColor),
                  ),
          ),
          const SizedBox(width: 6),
          Text(
            event.creatorName!,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
        const Spacer(),
        // Action button
        if (isCreator)
          _buildOutlineButton(
            label: 'Edit',
            color: accentColor,
            onTap: () {
              // TODO: Navigate to edit event
            },
          )
        else if (event.isJoinedByMe)
          _buildOutlineButton(
            label: 'Leave',
            color: AppColors.error,
            onTap: () {
              if (userId == null) return;
              context.read<EventBloc>().add(
                    LeaveEvent(eventId: event.id, userId: userId),
                  );
            },
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
              backgroundColor: accentColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              canJoin ? 'Join' : (!event.isUpcoming ? 'Ended' : 'Full'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildOutlineButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }

  Color _parseColor(String colorStr) {
    try {
      // Support both '#RRGGBB' and '0xFFRRGGBB' formats
      final hex = colorStr.replaceAll('#', '').replaceAll('0x', '');
      return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  IconData _getIconFromName(String? iconName) {
    switch (iconName) {
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
}