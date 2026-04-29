import 'package:flutter/material.dart';
import 'package:ploopy/core/theme/app_colors.dart';
import 'package:ploopy/core/theme/app_text_styles.dart';

class GameResultDialog extends StatelessWidget {
  final int moves;
  final int seconds;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const GameResultDialog({
    super.key,
    required this.moves,
    required this.seconds,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Game Selesai!',
              style: AppTextStyles.heading.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummary('Moves', '$moves'),
                _buildSummary('Waktu', '${seconds}s'),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onRestart();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Text('Main Lagi', style: AppTextStyles.buttonPrimary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onExit();
              },
              child: Text(
                'Keluar',
                style: AppTextStyles.body.copyWith(color: AppColors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading.copyWith(
            color: AppColors.primary,
            fontSize: 24,
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  static void show(
    BuildContext context, {
    required int moves,
    required int seconds,
    required VoidCallback onRestart,
    required VoidCallback onExit,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => GameResultDialog(
            moves: moves,
            seconds: seconds,
            onRestart: onRestart,
            onExit: onExit,
          ),
    );
  }
}
