// event/presentation/pages/full_screen_map_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class FullScreenMapPage extends StatefulWidget {
  final LatLng userLocation;
  final LatLng destination;
  final String destinationName;
  final List<LatLng> routePoints;

  const FullScreenMapPage({
    super.key,
    required this.userLocation,
    required this.destination,
    required this.destinationName,
    required this.routePoints,
  });

  @override
  State<FullScreenMapPage> createState() => _FullScreenMapPageState();
}

class _FullScreenMapPageState extends State<FullScreenMapPage> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Full screen map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                (widget.userLocation.latitude + widget.destination.latitude) / 2,
                (widget.userLocation.longitude + widget.destination.longitude) / 2,
              ),
              initialZoom: 16,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePoints,
                    strokeWidth: 5,
                    color: AppColors.black,
                    borderColor: AppColors.white,
                    borderStrokeWidth: 3,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.userLocation,
                    width: 50,
                    height: 50,
                    child: _buildMarker(Icons.person, AppColors.black),
                  ),
                  Marker(
                    point: widget.destination,
                    width: 50,
                    height: 50,
                    child: _buildMarker(Icons.location_on, AppColors.black),
                  ),
                ],
              ),
            ],
          ),
          // Floating controls
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const Spacer(),
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close, size: 20, color: AppColors.black),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Navigasi',
                style: AppTextStyles.caption.copyWith(color: AppColors.grey),
              ),
              Text(
                widget.destinationName,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.zoom_in,
            label: 'Zoom In',
            onTap: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom + 1,
              );
            },
          ),
          _buildControlButton(
            icon: Icons.zoom_out,
            label: 'Zoom Out',
            onTap: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom - 1,
              );
            },
          ),
          _buildControlButton(
            icon: Icons.my_location,
            label: 'Lokasi Saya',
            onTap: () => _mapController.move(widget.userLocation, 17),
          ),
          _buildControlButton(
            icon: Icons.directions,
            label: 'Ke Tujuan',
            onTap: () => _mapController.move(widget.destination, 17),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: AppColors.black),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarker(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.white, size: 22),
      ),
    );
  }
}