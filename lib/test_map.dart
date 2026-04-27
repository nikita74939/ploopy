import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TestMapPage extends StatefulWidget {
  const TestMapPage({super.key});

  @override
  State<TestMapPage> createState() => _TestMapPageState();
}

class _TestMapPageState extends State<TestMapPage> {
  // Koordinat Monas sebagai default
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-6.1754, 106.8272),
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Map 🗺️'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        markers: {
          const Marker(
            // const di sini tetap boleh
            markerId: MarkerId('monas'),
            position: LatLng(-6.1754, 106.8272),
            infoWindow: InfoWindow(
              title: 'Monas',
              snippet: 'Monumen Nasional, Jakarta',
            ),
          ),
        },
      ),
    );
  }
}
