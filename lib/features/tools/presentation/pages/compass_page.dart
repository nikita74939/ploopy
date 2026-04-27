import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/compass_dial.dart';
import '../widgets/compass_info_card.dart';
import '../widgets/compass_permission_view.dart';

class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  double _heading = 0;
  bool _hasPermission = false;
  bool _hasSensor = true;
  bool _isChecking = true;
  StreamSubscription<CompassEvent>? _compassSub;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.locationWhenInUse.status;

    if (status.isGranted) {
      _startCompass();
    } else {
      setState(() {
        _hasPermission = false;
        _isChecking = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      _startCompass();
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      setState(() => _hasPermission = false);
    }
  }

  void _startCompass() {
    setState(() {
      _hasPermission = true;
      _isChecking = false;
    });

    // Cek apakah device punya sensor compass
    FlutterCompass.events?.first.then((event) {
      if (event.heading == null) {
        setState(() => _hasSensor = false);
      }
    });

    _compassSub = FlutterCompass.events?.listen((event) {
      if (event.heading != null && mounted) {
        setState(() {
          // Normalize 0-360
          _heading = event.heading! < 0
              ? event.heading! + 360
              : event.heading!;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: SafeArea(child: _buildBody()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey.shade50,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Kompas',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    if (_isChecking) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (!_hasPermission || !_hasSensor) {
      return CompassPermissionView(
        hasPermission: _hasPermission,
        hasSensor: _hasSensor,
        onRequestPermission: _requestPermission,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CompassInfoCard(heading: _heading),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CompassDial(heading: _heading),
          ),
          const SizedBox(height: 24),
          _buildTipsCard(),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text('💡', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Akurasi',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Jauhkan dari benda logam & elektronik. Kalibrasi dengan gerakan angka 8.',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}