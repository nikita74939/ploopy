// event/presentation/pages/event_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ploopy/features/event/presentation/pages/event_route_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/event_model.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPoster(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryBadge(),
                      const SizedBox(height: 12),
                      _buildTitle(),
                      const SizedBox(height: 20),
                      _buildOrganizer(),
                      const SizedBox(height: 24),
                      _buildDetailsSection(),
                      if (event.hasLocation) ...[
                        const SizedBox(height: 24),
                        _buildLocationSection(context),
                        const SizedBox(height: 24),
                        _buildMap(context),
                      ],
                      const SizedBox(height: 24),
                      _buildDescription(),
                      const SizedBox(height: 24),
                      _buildParticipants(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.black,
            size: 20,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.black,
              size: 20,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildPoster() {
    if (event.imageUrl != null) {
      return Container(
        height: 240,
        width: double.infinity,
        color: AppColors.greyLight,
        child: Image.network(
          event.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackPoster(),
        ),
      );
    }
    return _buildFallbackPoster();
  }

  Widget _buildFallbackPoster() {
    return Container(
      height: 240,
      width: double.infinity,
      color: AppColors.greyLight,
      alignment: Alignment.center,
      child: Text(
        event.title.substring(0, 2).toUpperCase(),
        style: AppTextStyles.heading.copyWith(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: AppColors.grey,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Event',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      event.title,
      style: AppTextStyles.heading.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
        height: 1.2,
      ),
    );
  }

  Widget _buildOrganizer() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.person_outline,
            color: AppColors.grey,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diselenggarakan oleh',
              style: AppTextStyles.caption.copyWith(color: AppColors.grey),
            ),
            Text(
              event.organizerName,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            Icons.calendar_today_outlined,
            _formatDate(event.dateTime),
          ),
          const SizedBox(height: 14),
          _buildDetailRow(
            Icons.access_time_outlined,
            _formatTime(event.dateTime),
          ),
          if (event.location != null) ...[
            const SizedBox(height: 14),
            _buildDetailRow(Icons.location_on_outlined, event.location!),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.black),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lokasi',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _openRoutePage(context),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  size: 20,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.location ?? 'Lokasi tidak tersedia',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      'Klik untuk lihat rute',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMap(BuildContext context) {
    final center = LatLng(event.latitude!, event.longitude!);

    return GestureDetector(
      onTap: () => _openRoutePage(context),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.greyBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 16,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Overlay hint
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.open_in_new,
                      size: 14,
                      color: AppColors.black,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Lihat Rute',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRoutePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventRoutePage(
          destLat: event.latitude!,
          destLng: event.longitude!,
          destinationName: event.location ?? 'Lokasi Event',
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          event.description,
          style: AppTextStyles.body.copyWith(
            color: AppColors.grey,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipants() {
    final percentage = event.currentParticipants / event.maxParticipants;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Peserta',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const Spacer(),
            Text(
              '${event.currentParticipants}/${event.maxParticipants}',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: AppColors.greyLight,
            valueColor: const AlwaysStoppedAnimation(AppColors.black),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${event.spotsLeft} spot tersisa',
          style: AppTextStyles.caption.copyWith(color: AppColors.grey),
        ),
        const SizedBox(height: 16),
        // Participant avatars
        SizedBox(
          height: 40,
          child: Stack(
            children: List.generate(
              event.currentParticipants.clamp(0, 5),
              (index) => Positioned(
                left: index * 28.0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(Icons.person, size: 18, color: AppColors.grey),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.greyBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.isFull ? 'Penuh' : 'Tersedia',
                  style: AppTextStyles.caption.copyWith(color: AppColors.grey),
                ),
                if (!event.isFull)
                  Text(
                    '${event.spotsLeft} spot tersisa',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: event.isJoined ? null : () => _handleJoin(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color:
                    event.isJoined
                        ? AppColors.greyLight
                        : event.isFull
                        ? AppColors.grey
                        : AppColors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                event.isJoined ? 'Joined' : 'Join Event',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: event.isJoined ? AppColors.grey : AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleJoin(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil join event: ${event.title}'),
        backgroundColor: AppColors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }
}