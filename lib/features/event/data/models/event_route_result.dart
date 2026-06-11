import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventRouteResult {
  final LatLng origin;
  final LatLng destination;
  final List<LatLng> polyline;
  final String distanceText;
  final String durationText;

  const EventRouteResult({
    required this.origin,
    required this.destination,
    required this.polyline,
    required this.distanceText,
    required this.durationText,
  });
}
