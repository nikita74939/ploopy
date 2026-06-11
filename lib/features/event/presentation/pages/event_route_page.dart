import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/event_entity.dart';
import '../bloc/event_route_bloc.dart';

class EventRoutePage extends StatefulWidget {
  final EventEntity event;

  const EventRoutePage({super.key, required this.event});

  @override
  State<EventRoutePage> createState() => _EventRoutePageState();
}

class _EventRoutePageState extends State<EventRoutePage> {
  GoogleMapController? _mapController;

  LatLng get _destination =>
      LatLng(widget.event.latitude!, widget.event.longitude!);

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.event.hasCoordinates) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _appBar(),
        body: const _RouteMessage(
          icon: Icons.location_off_rounded,
          title: 'Lokasi event belum tersedia',
          message: 'Event ini belum memiliki latitude dan longitude.',
        ),
      );
    }

    return BlocProvider(
      create: (_) =>
          DependencyInjection.eventRouteBloc
            ..add(LoadEventRoute(destination: _destination)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _appBar(),
        body: BlocConsumer<EventRouteBloc, EventRouteState>(
          listener: (context, state) {
            if (state is EventRouteLoaded) {
              _fitRoute(state.route.origin, state.route.destination);
            }
          },
          builder: (context, state) {
            if (state is EventRouteLoading || state is EventRouteInitial) {
              return const _RouteMessage(
                icon: Icons.route_rounded,
                title: 'Menghitung rute',
                message: 'Ploopy sedang mengambil lokasi kamu dan rute event.',
                loading: true,
              );
            }

            if (state is EventRoutePermissionDenied) {
              return _RouteMessage(
                icon: Icons.location_disabled_rounded,
                title: 'Izin lokasi diperlukan',
                message: state.message,
                onRetry: () => context.read<EventRouteBloc>().add(
                  LoadEventRoute(destination: _destination),
                ),
              );
            }

            if (state is EventRouteError) {
              return _RouteMessage(
                icon: Icons.error_outline_rounded,
                title: 'Rute gagal dimuat',
                message: state.message,
                onRetry: () => context.read<EventRouteBloc>().add(
                  LoadEventRoute(destination: _destination),
                ),
              );
            }

            final loaded = state as EventRouteLoaded;
            final route = loaded.route;
            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: route.destination,
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _fitRoute(route.origin, route.destination);
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('user_location'),
                      position: route.origin,
                      infoWindow: const InfoWindow(title: 'Lokasi kamu'),
                    ),
                    Marker(
                      markerId: const MarkerId('event_location'),
                      position: route.destination,
                      infoWindow: InfoWindow(title: widget.event.name),
                    ),
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('event_route'),
                      points: route.polyline,
                      width: 6,
                      color: AppColors.primary,
                    ),
                  },
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: _RouteSummaryCard(
                    event: widget.event,
                    distance: route.distanceText,
                    duration: route.durationText,
                    onNavigate: () async {
                      try {
                        await DependencyInjection.eventLocationService
                            .openGoogleMapsNavigation(route.destination);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Text('Rute Event', style: AppTextStyles.title),
    );
  }

  Future<void> _fitRoute(LatLng origin, LatLng destination) async {
    final controller = _mapController;
    if (controller == null) return;
    final southWest = LatLng(
      origin.latitude < destination.latitude
          ? origin.latitude
          : destination.latitude,
      origin.longitude < destination.longitude
          ? origin.longitude
          : destination.longitude,
    );
    final northEast = LatLng(
      origin.latitude > destination.latitude
          ? origin.latitude
          : destination.latitude,
      origin.longitude > destination.longitude
          ? origin.longitude
          : destination.longitude,
    );
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southWest, northeast: northEast),
        72,
      ),
    );
  }
}

class _RouteSummaryCard extends StatelessWidget {
  final EventEntity event;
  final String distance;
  final String duration;
  final VoidCallback onNavigate;

  const _RouteSummaryCard({
    required this.event,
    required this.distance,
    required this.duration,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(event.name, style: AppTextStyles.title),
          const SizedBox(height: 6),
          Text(event.displayLocation, style: AppTextStyles.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Metric(icon: Icons.route_rounded, value: distance),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Metric(icon: Icons.schedule_rounded, value: duration),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onNavigate,
              icon: const Icon(Icons.navigation_rounded, size: 18),
              label: Text('Mulai Navigasi', style: AppTextStyles.buttonPrimary),
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
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value;

  const _Metric({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool loading;
  final VoidCallback? onRetry;

  const _RouteMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.loading = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const CircularProgressIndicator()
            else
              Icon(icon, size: 44, color: AppColors.primary),
            const SizedBox(height: 14),
            Text(title, style: AppTextStyles.title),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
