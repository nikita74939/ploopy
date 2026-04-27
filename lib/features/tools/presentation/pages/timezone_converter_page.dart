import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../../../../core/theme/app_colors.dart';
import '../widgets/timezone_card.dart';
import '../widgets/timezone_picker_sheet.dart';
import '../widgets/timezone_time_picker.dart';

class TimezoneConverterPage extends StatefulWidget {
  const TimezoneConverterPage({super.key});

  @override
  State<TimezoneConverterPage> createState() => _TimezoneConverterPageState();
}

class _TimezoneConverterPageState extends State<TimezoneConverterPage> {
  String _sourceTzId = 'Asia/Jakarta';
  DateTime _sourceDateTime = DateTime.now();

  // Destination timezones (bisa multiple)
  final List<String> _destinations = [
    'Asia/Tokyo',
    'Europe/London',
    'America/New_York',
  ];

  bool _isLive = true; // Update real-time
  Timer? _liveTimer;

  @override
  void initState() {
    super.initState();
    tz_data.initializeTimeZones();
    _startLiveTimer();
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  void _startLiveTimer() {
    _liveTimer?.cancel();
    _liveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isLive && mounted) {
        setState(() {
          _sourceDateTime = DateTime.now();
        });
      }
    });
  }

  /// Konversi waktu dari source timezone ke target timezone
  DateTime _convertTime(DateTime sourceTime, String sourceId, String targetId) {
    try {
      final sourceLocation = tz.getLocation(sourceId);
      final targetLocation = tz.getLocation(targetId);

      // Buat TZDateTime dari sourceTime di source timezone
      final sourceTz = tz.TZDateTime(
        sourceLocation,
        sourceTime.year,
        sourceTime.month,
        sourceTime.day,
        sourceTime.hour,
        sourceTime.minute,
        sourceTime.second,
      );

      // Convert ke target timezone
      final targetTz = tz.TZDateTime.from(sourceTz, targetLocation);

      return DateTime(
        targetTz.year,
        targetTz.month,
        targetTz.day,
        targetTz.hour,
        targetTz.minute,
        targetTz.second,
      );
    } catch (e) {
      return sourceTime;
    }
  }

  Future<void> _pickSourceTimezone() async {
    final id = await TimezonePickerSheet.show(context, _sourceTzId);
    if (id != null && id != _sourceTzId) {
      setState(() => _sourceTzId = id);
    }
  }

  Future<void> _pickDestTimezone(int index) async {
    final id = await TimezonePickerSheet.show(context, _destinations[index]);
    if (id != null) {
      setState(() => _destinations[index] = id);
    }
  }

  void _removeDestination(int index) {
    setState(() => _destinations.removeAt(index));
  }

  Future<void> _addDestination() async {
    final id = await TimezonePickerSheet.show(context, '');
    if (id != null && !_destinations.contains(id) && id != _sourceTzId) {
      setState(() => _destinations.add(id));
    }
  }

  void _onDateTimeChanged(DateTime dt) {
    setState(() {
      _sourceDateTime = dt;
      _isLive = false;
    });
  }

  void _resetToNow() {
    setState(() {
      _isLive = true;
      _sourceDateTime = DateTime.now();
    });
  }

  int _calculateDiffHours(String targetId) {
    final now = DateTime.now();
    final converted = _convertTime(now, _sourceTzId, targetId);
    final diff = converted.difference(now).inMinutes;
    return diff;
  }

  String _formatDiff(int minutes) {
    if (minutes == 0) return 'Sama waktunya';
    final hours = minutes.abs() ~/ 60;
    final mins = minutes.abs() % 60;
    final sign = minutes > 0 ? 'lebih cepat' : 'lebih lambat';

    if (mins == 0) {
      return '$hours jam $sign';
    }
    return '$hours jam $mins menit $sign';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSourceSection(),
              const SizedBox(height: 20),
              _buildDestinationsSection(),
              const SizedBox(height: 14),
              _buildAddButton(),
            ],
          ),
        ),
      ),
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
        'Konversi Zona Waktu',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSourceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Zona Waktu Sumber',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        TimezoneCard(
          label: 'SUMBER WAKTU',
          timezoneId: _sourceTzId,
          dateTime: _sourceDateTime,
          onTimezoneTap: _pickSourceTimezone,
          highlighted: true,
        ),
        const SizedBox(height: 10),
        TimezoneTimePicker(
          selectedDateTime: _sourceDateTime,
          onChanged: _onDateTimeChanged,
          onResetToNow: _resetToNow,
        ),
      ],
    );
  }

  Widget _buildDestinationsSection() {
    if (_destinations.isEmpty) {
      return _buildEmptyDestinations();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Text(
                'Dikonversi ke',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_destinations.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(_destinations.length, (i) {
          final destId = _destinations[i];
          final convertedTime = _convertTime(
            _sourceDateTime,
            _sourceTzId,
            destId,
          );
          final diffMinutes = _calculateDiffHours(destId);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Dismissible(
              key: ValueKey('$destId-$i'),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => _removeDestination(i),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              child: Column(
                children: [
                  TimezoneCard(
                    label: _formatDiff(diffMinutes).toUpperCase(),
                    timezoneId: destId,
                    dateTime: convertedTime,
                    onTimezoneTap: () => _pickDestTimezone(i),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyDestinations() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Center(
        child: Column(
          children: [
            const Text('🌐', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(
              'Belum ada zona waktu tujuan',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap tombol di bawah untuk menambahkan',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _addDestination,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Tambah Zona Waktu',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
