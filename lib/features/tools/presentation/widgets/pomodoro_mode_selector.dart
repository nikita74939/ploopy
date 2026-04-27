import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum PomodoroMode { focus, shortBreak, longBreak }

class PomodoroModeSelector extends StatelessWidget {
  final PomodoroMode selectedMode;
  final ValueChanged<PomodoroMode> onChanged;

  const PomodoroModeSelector({
    super.key,
    required this.selectedMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildTab(
            label: 'Fokus',
            emoji: '🎯',
            mode: PomodoroMode.focus,
            selectedColor: const Color(0xFFFF6B6B),
          ),
          _buildTab(
            label: 'Istirahat',
            emoji: '☕',
            mode: PomodoroMode.shortBreak,
            selectedColor: const Color(0xFF6BCB77),
          ),
          _buildTab(
            label: 'Panjang',
            emoji: '😴',
            mode: PomodoroMode.longBreak,
            selectedColor: const Color(0xFF4D96FF),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required String emoji,
    required PomodoroMode mode,
    required Color selectedColor,
  }) {
    final isSelected = selectedMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(mode),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? selectedColor : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}