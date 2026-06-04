import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/bottom_sheet_insets.dart';

class PomodoroSettings {
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;

  const PomodoroSettings({
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
  });

  PomodoroSettings copyWith({
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsBeforeLongBreak,
  }) {
    return PomodoroSettings(
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
    );
  }
}

class PomodoroSettingsSheet extends StatefulWidget {
  final PomodoroSettings settings;

  const PomodoroSettingsSheet({super.key, required this.settings});

  static Future<PomodoroSettings?> show(
    BuildContext context,
    PomodoroSettings settings,
  ) {
    return showModalBottomSheet<PomodoroSettings>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PomodoroSettingsSheet(settings: settings),
    );
  }

  @override
  State<PomodoroSettingsSheet> createState() => _PomodoroSettingsSheetState();
}

class _PomodoroSettingsSheetState extends State<PomodoroSettingsSheet> {
  late PomodoroSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              BottomSheetInsets.bottom(context),
            ),
            child: Column(
              children: [
                _buildItem(
                  emoji: '🎯',
                  label: 'Fokus',
                  value: _settings.focusMinutes,
                  minValue: 5,
                  maxValue: 60,
                  unit: 'menit',
                  onChanged: (v) => setState(() {
                    _settings = _settings.copyWith(focusMinutes: v);
                  }),
                ),
                const SizedBox(height: 10),
                _buildItem(
                  emoji: '☕',
                  label: 'Istirahat',
                  value: _settings.shortBreakMinutes,
                  minValue: 1,
                  maxValue: 15,
                  unit: 'menit',
                  onChanged: (v) => setState(() {
                    _settings = _settings.copyWith(shortBreakMinutes: v);
                  }),
                ),
                const SizedBox(height: 10),
                _buildItem(
                  emoji: '😴',
                  label: 'Istirahat Panjang',
                  value: _settings.longBreakMinutes,
                  minValue: 10,
                  maxValue: 30,
                  unit: 'menit',
                  onChanged: (v) => setState(() {
                    _settings = _settings.copyWith(longBreakMinutes: v);
                  }),
                ),
                const SizedBox(height: 10),
                _buildItem(
                  emoji: '🔄',
                  label: 'Sesi sebelum istirahat panjang',
                  value: _settings.sessionsBeforeLongBreak,
                  minValue: 2,
                  maxValue: 8,
                  unit: 'sesi',
                  onChanged: (v) => setState(() {
                    _settings = _settings.copyWith(sessionsBeforeLongBreak: v);
                  }),
                ),
                const SizedBox(height: 20),
                _buildSaveButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Row(
        children: [
          Text(
            'Pengaturan Timer',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String emoji,
    required String label,
    required int value,
    required int minValue,
    required int maxValue,
    required String unit,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          _buildSpinner(value, minValue, maxValue, unit, onChanged),
        ],
      ),
    );
  }

  Widget _buildSpinner(
    int value,
    int min,
    int max,
    String unit,
    ValueChanged<int> onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          _buildSpinnerButton(
            icon: Icons.remove_rounded,
            onTap: value > min ? () => onChanged(value - 1) : null,
          ),
          Container(
            width: 50,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$value',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  unit,
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          _buildSpinnerButton(
            icon: Icons.add_rounded,
            onTap: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSpinnerButton({required IconData icon, VoidCallback? onTap}) {
    final enabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 32,
          height: 38,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 16,
            color: enabled ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => Navigator.pop(context, _settings),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: Text(
              'Simpan Pengaturan',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
