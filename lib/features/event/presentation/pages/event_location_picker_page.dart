import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/datasources/event_location_service.dart';
import '../../data/models/event_location_result.dart';

class EventLocationPickerPage extends StatefulWidget {
  final EventLocationResult? initialLocation;

  const EventLocationPickerPage({super.key, this.initialLocation});

  @override
  State<EventLocationPickerPage> createState() =>
      _EventLocationPickerPageState();
}

class _EventLocationPickerPageState extends State<EventLocationPickerPage> {
  late final EventLocationService _locationService;
  GoogleMapController? _mapController;
  LatLng? _selectedPoint;
  String? _address;
  String? _placeId;
  bool _loading = true;
  bool _resolvingAddress = false;
  String? _error;

  static const _fallbackPoint = LatLng(-6.200000, 106.816666);

  @override
  void initState() {
    super.initState();
    _locationService = DependencyInjection.eventLocationService;
    _initialize();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final initial = widget.initialLocation;
    if (initial != null) {
      setState(() {
        _selectedPoint = LatLng(initial.latitude, initial.longitude);
        _address = initial.address;
        _placeId = initial.placeId;
        _loading = false;
      });
      return;
    }

    try {
      final position = await _locationService.getCurrentPosition();
      final point = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedPoint = point;
        _loading = false;
      });
      await _selectPoint(point, animate: false);
    } catch (_) {
      setState(() {
        _selectedPoint = _fallbackPoint;
        _address = 'Pilih titik lokasi event di peta.';
        _loading = false;
        _error =
            'Lokasi saat ini belum tersedia. Kamu tetap bisa memilih titik secara manual.';
      });
    }
  }

  Future<void> _selectPoint(LatLng point, {bool animate = true}) async {
    setState(() {
      _selectedPoint = point;
      _resolvingAddress = true;
      _error = null;
    });
    if (animate) {
      await _mapController?.animateCamera(CameraUpdate.newLatLng(point));
    }

    try {
      final result = await _locationService.reverseGeocode(point);
      if (!mounted) return;
      setState(() {
        _address = result.address;
        _placeId = result.placeId;
        _resolvingAddress = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _address =
            '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
        _resolvingAddress = false;
      });
    }
  }

  void _useSelectedLocation() {
    final point = _selectedPoint;
    if (point == null) return;
    Navigator.pop(
      context,
      EventLocationResult(
        latitude: point.latitude,
        longitude: point.longitude,
        address: _address,
        placeId: _placeId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final point = _selectedPoint ?? _fallbackPoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Pilih Lokasi Event', style: AppTextStyles.title),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: point,
                      zoom: 15,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                    onMapCreated: (controller) => _mapController = controller,
                    onTap: _selectPoint,
                    markers: {
                      Marker(
                        markerId: const MarkerId('selected_event_location'),
                        position: point,
                        infoWindow: const InfoWindow(title: 'Lokasi Event'),
                      ),
                    },
                  ),
                ),
                _BottomPanel(
                  address: _address,
                  error: _error,
                  resolvingAddress: _resolvingAddress,
                  onUseLocation: _useSelectedLocation,
                ),
              ],
            ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  final String? address;
  final String? error;
  final bool resolvingAddress;
  final VoidCallback onUseLocation;

  const _BottomPanel({
    required this.address,
    required this.error,
    required this.resolvingAddress,
    required this.onUseLocation,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.greyBorder)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Lokasi dipilih', style: AppTextStyles.title),
              ],
            ),
            const SizedBox(height: 8),
            if (resolvingAddress)
              Text('Membaca alamat...', style: AppTextStyles.bodySmall)
            else
              Text(
                address ?? 'Tap peta untuk memilih titik lokasi.',
                style: AppTextStyles.bodySmall.copyWith(height: 1.45),
              ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error!,
                style: AppTextStyles.small.copyWith(color: AppColors.warning),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onUseLocation,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(
                  'Gunakan Lokasi Ini',
                  style: AppTextStyles.buttonPrimary,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
