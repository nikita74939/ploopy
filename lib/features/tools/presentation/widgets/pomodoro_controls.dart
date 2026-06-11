import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PomodoroControls extends StatelessWidget {
  final bool isRunning;
  final bool isPaused;
  final Color accentColor;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;
  final VoidCallback onSkip;

  const PomodoroControls({
    super.key,
    required this.isRunning,
    required this.isPaused,
    required this.accentColor,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSecondaryButton(
          icon: Icons.refresh_rounded,
          onTap: onReset,
          tooltip: 'Reset',
        ),
        const SizedBox(width: 20),
        _buildPrimaryButton(),
        const SizedBox(width: 20),
        _buildSecondaryButton(
          icon: Icons.skip_next_rounded,
          onTap: onSkip,
          tooltip: 'Skip',
        ),
      ],
    );
  }

  Widget _buildPrimaryButton() {
    IconData icon;
    VoidCallback onTap;
    String label;

    if (!isRunning && !isPaused) {
      icon = Icons.play_arrow_rounded;
      onTap = onStart;
      label = 'Mulai';
    } else if (isPaused) {
      icon = Icons.play_arrow_rounded;
      onTap = onResume;
      label = 'Lanjut';
    } else {
      icon = Icons.pause_rounded;
      onTap = onPause;
      label = 'Jeda';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: accentColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: Colors.grey.shade700,
            size: 24,
          ),
        ),
      ),
    );
  }
}