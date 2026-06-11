import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/api_config.dart';
import '../models/event_location_result.dart';
import '../models/event_route_result.dart';

class EventLocationService {
  final http.Client client;
  final String googleMapsApiKey;

  EventLocationService({required this.client, String? googleMapsApiKey})
    : googleMapsApiKey = googleMapsApiKey ?? ApiConfig.googleMapsApiKey;

  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationPermissionDeniedException();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionDeniedForeverException();
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<EventLocationResult> reverseGeocode(LatLng point) async {
    if (googleMapsApiKey.isEmpty) {
      return EventLocationResult(
        latitude: point.latitude,
        longitude: point.longitude,
        address: _coordinateLabel(point),
      );
    }

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '${point.latitude},${point.longitude}',
      'key': googleMapsApiKey,
      'language': 'id',
    });
    final response = await client.get(uri).timeout(const Duration(seconds: 12));
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal membaca alamat lokasi.');
    }

    final results = body['results'] as List? ?? const [];
    if (results.isEmpty) {
      return EventLocationResult(
        latitude: point.latitude,
        longitude: point.longitude,
        address: _coordinateLabel(point),
      );
    }

    final first = results.first as Map<String, dynamic>;
    return EventLocationResult(
      latitude: point.latitude,
      longitude: point.longitude,
      address:
          first['formatted_address']?.toString() ?? _coordinateLabel(point),
      placeId: first['place_id']?.toString(),
    );
  }

  Future<EventRouteResult> fetchRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    if (googleMapsApiKey.isEmpty) {
      throw Exception('GOOGLE_MAPS_API_KEY belum diatur di .env Flutter.');
    }

    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': 'driving',
      'key': googleMapsApiKey,
      'language': 'id',
    });
    final response = await client.get(uri).timeout(const Duration(seconds: 15));
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal mengambil rute dari Google Maps.');
    }

    final status = body['status']?.toString();
    if (status != 'OK') {
      final message = body['error_message']?.toString();
      throw Exception(message ?? 'Rute ke event belum tersedia.');
    }

    final routes = body['routes'] as List? ?? const [];
    if (routes.isEmpty) {
      throw Exception('Rute ke event belum tersedia.');
    }
    final route = routes.first as Map<String, dynamic>;
    final legs = route['legs'] as List? ?? const [];
    final leg = legs.isNotEmpty ? legs.first as Map<String, dynamic> : null;
    final encoded = route['overview_polyline']?['points']?.toString();
    if (encoded == null || encoded.isEmpty) {
      throw Exception('Google Maps tidak mengembalikan polyline rute.');
    }

    return EventRouteResult(
      origin: origin,
      destination: destination,
      polyline: _decodePolyline(encoded),
      distanceText: leg?['distance']?['text']?.toString() ?? '-',
      durationText: leg?['duration']?['text']?.toString() ?? '-',
    );
  }

  Future<void> openGoogleMapsNavigation(LatLng destination) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${destination.latitude},${destination.longitude}'
      '&travelmode=driving',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw Exception('Tidak bisa membuka Google Maps.');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    var lat = 0;
    var lng = 0;

    while (index < encoded.length) {
      var shift = 0;
      var result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  String _coordinateLabel(LatLng point) {
    return '${point.latitude.toStringAsFixed(6)}, '
        '${point.longitude.toStringAsFixed(6)}';
  }
}

class LocationPermissionDeniedException implements Exception {
  const LocationPermissionDeniedException();
}

class LocationPermissionDeniedForeverException implements Exception {
  const LocationPermissionDeniedForeverException();
}
