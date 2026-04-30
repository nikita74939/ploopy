// event/presentation/pages/event_page.dart (dengan BLoC)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/event_bloc.dart';
import '../widgets/event_card.dart';
import 'event_detail_page.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  int _selectedFilter = 0;

  final List<String> _filters = ['Semua', 'Terdekat', 'Joined', 'Terbaru'];

  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(LoadEvents());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(),
          _buildFilters(),
          Expanded(
            child: BlocBuilder<EventBloc, EventState>(
              builder: (context, state) {
                if (state is EventLoading) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                
                if (state is EventError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: AppTextStyles.body.copyWith(color: AppColors.grey),
                    ),
                  );
                }
                
                if (state is EventLoaded) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                    children: [
                      _buildBanner(state),
                      const SizedBox(height: 12),
                      ...state.filteredEvents.map(
                        (e) => EventCard(
                          event: {
                            'title': e.title,
                            'category': 'Event',
                            'date': _formatDate(e.dateTime),
                            'time': _formatTime(e.dateTime),
                            'location': e.location,
                            'distance': e.hasLocation ? '~500m' : null,
                            'participants': e.currentParticipants,
                            'maxParticipants': e.maxParticipants,
                            'coverColor': AppColors.greyDark,
                            'emoji': e.title.substring(0, 2).toUpperCase(),
                            'joined': e.isJoined,
                            'imageUrl': e.imageUrl,
                            'latitude': e.latitude,
                            'longitude': e.longitude,
                          },
                          onTap: () => _navigateToDetail(e),
                        ),
                      ),
                    ],
                  );
                }
                
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.greyBorder)),
      ),
      child: Row(
        children: [
          Text(
            'Event',
            style: AppTextStyles.heading.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.black),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.greyBorder)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(_filters.length, (index) {
            final isSelected = _selectedFilter == index;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = index);
                context.read<EventBloc>().add(FilterEvents(index));
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.black : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.black : AppColors.greyBorder,
                  ),
                ),
                child: Text(
                  _filters[index],
                  style: AppTextStyles.small.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.white : AppColors.grey,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBanner(EventLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Temukan Event\nyang Tepat Untukmu',
            style: AppTextStyles.heading.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ikuti event dan expand networkingmu',
            style: AppTextStyles.small.copyWith(
              color: AppColors.greyLight,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBannerStat('${state.events.length}+', 'Event Aktif'),
              const SizedBox(width: 24),
              _buildBannerStat(
                '${state.events.fold<int>(0, (sum, e) => sum + e.currentParticipants)}+',
                'Peserta',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.heading.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.grey),
        ),
      ],
    );
  }

  void _navigateToDetail(dynamic event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailPage(event: event),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}