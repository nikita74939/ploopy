// event/presentation/pages/event_route_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ploopy/features/event/presentation/pages/full_screen_map_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class EventRoutePage extends StatefulWidget {
  final double destLat;
  final double destLng;
  final String destinationName;

  const EventRoutePage({
    super.key,
    required this.destLat,
    required this.destLng,
    required this.destinationName,
  });

  @override
  State<EventRoutePage> createState() => _EventRoutePageState();
}

class _EventRoutePageState extends State<EventRoutePage> {
  final MapController _mapController = MapController();
  
  // Lokasi contoh (Universitas)
  static const double _userLat = -6.8916;
  static const double _userLng = 107.6107;
  
  late LatLng _userLocation;
  late LatLng _destination;
  
  // Route points (simplified - bisa diganti dengan real routing API)
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _userLocation = const LatLng(_userLat, _userLng);
    _destination = LatLng(widget.destLat, widget.destLng);
    _generateRoute();
  }

  void _generateRoute() {
    // Generate simplified route (straight line dengan beberapa waypoints)
    // Untuk production, bisa gunakan OpenRouteService atau OSRM API
    _routePoints = [
      _userLocation,
      LatLng((_userLat + widget.destLat) / 2, (_userLng + widget.destLng) / 2 + 0.001),
      LatLng((_userLat + widget.destLat) / 2 + 0.0005, (_userLng + widget.destLng) / 2 - 0.0005),
      _destination,
    ];
  }

  double get _distance {
    const distance = Distance();
    return distance.as(
      LengthUnit.Meter,
      _userLocation,
      _destination,
    );
  }

  String get _distanceText {
    if (_distance >= 1000) {
      return '${(_distance / 1000).toStringAsFixed(1)} km';
    }
    return '${_distance.round()} m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  _buildMap(),
                  _buildBottomInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.greyBorder)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.black,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rute ke Lokasi',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  widget.destinationName,
                  style: AppTextStyles.caption.copyWith(color: AppColors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _centerOnRoute(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.my_location_rounded,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(
          (_userLat + widget.destLat) / 2,
          (_userLng + widget.destLng) / 2,
        ),
        initialZoom: 16,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        // CartoDB Light tiles (clean, minimalist)
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.app',
        ),
        
        // Route polyline
        PolylineLayer(
          polylines: [
            Polyline(
              points: _routePoints,
              strokeWidth: 4,
              color: AppColors.black,
              borderColor: AppColors.white,
              borderStrokeWidth: 2,
            ),
          ],
        ),
        
        // Markers
        MarkerLayer(
          markers: [
            // User location marker
            Marker(
              point: _userLocation,
              width: 50,
              height: 50,
              child: _buildUserMarker(),
            ),
            // Destination marker
            Marker(
              point: _destination,
              width: 50,
              height: 50,
              child: _buildDestinationMarker(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserMarker() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.black,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person,
          color: AppColors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildDestinationMarker() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.black,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.location_on,
          color: AppColors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Distance info
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.directions_walk_rounded,
                    color: AppColors.black,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jarak',
                        style: AppTextStyles.caption.copyWith(color: AppColors.grey),
                      ),
                      Text(
                        _distanceText,
                        style: AppTextStyles.heading.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Estimasi',
                      style: AppTextStyles.caption.copyWith(color: AppColors.grey),
                    ),
                    Text(
                      '${(_distance / 80).ceil()} menit',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.list_alt_rounded,
                    label: 'Daftar Titik',
                    onTap: () => _showWaypoints(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.fullscreen_rounded,
                    label: 'Full Screen',
                    onTap: () => _toggleFullScreen(),
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.black : AppColors.greyLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? AppColors.white : AppColors.black,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.small.copyWith(
                fontWeight: FontWeight.w600,
                color: isPrimary ? AppColors.white : AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _centerOnRoute() {
    _mapController.move(
      LatLng(
        (_userLat + widget.destLat) / 2,
        (_userLng + widget.destLng) / 2,
      ),
      15,
    );
  }

// event/presentation/pages/event_route_page.dart (lanjutan)

  void _showWaypoints() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Titik Rute',
              style: AppTextStyles.heading.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildWaypointItem(
              index: 1,
              icon: Icons.person,
              title: 'Lokasi Kamu',
              subtitle: 'Posisi saat ini',
              isFirst: true,
            ),
            _buildWaypointItem(
              index: 2,
              icon: Icons.turn_right_rounded,
              title: 'Pertigaan Utama',
              subtitle: 'Belok kanan',
            ),
            _buildWaypointItem(
              index: 3,
              icon: Icons.turn_left_rounded,
              title: 'Depan Kantin',
              subtitle: 'Lurus 100m',
            ),
            _buildWaypointItem(
              index: 4,
              icon: Icons.location_on,
              title: widget.destinationName,
              subtitle: 'Tujuan',
              isLast: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWaypointItem({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: AppColors.white),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 24,
                  color: AppColors.greyBorder,
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(color: AppColors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFullScreen() {
    // Implement full screen map mode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenMapPage(
          userLocation: _userLocation,
          destination: _destination,
          destinationName: widget.destinationName,
          routePoints: _routePoints,
        ),
      ),
    );
  }
}