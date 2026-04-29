import 'package:flutter/material.dart';

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

  String get _formattedTime {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _rating {
    if (moves <= 12) return '⭐⭐⭐';
    if (moves <= 18) return '⭐⭐';
    return '⭐';
  }

  String get _ratingLabel {
    if (moves <= 12) return 'Luar Biasa!';
    if (moves <= 18) return 'Bagus!';
    return 'Terus Berlatih!';
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
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => GameResultDialog(
        moves: moves,
        seconds: seconds,
        onRestart: onRestart,
        onExit: onExit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2F4E), Color(0xFF0F1E33)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF2D6A9F).withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D6A9F).withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB74D).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFFFB74D),
                size: 48,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              _ratingLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _rating,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 20),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ResultStat(
                  icon: Icons.touch_app_rounded,
                  label: 'Moves',
                  value: '$moves',
                  color: const Color(0xFF64B5F6),
                ),
                _ResultStat(
                  icon: Icons.timer_rounded,
                  label: 'Waktu',
                  value: _formattedTime,
                  color: const Color(0xFF4CAF82),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onExit();
                    },
                    icon: const Icon(Icons.home_rounded, size: 18),
                    label: const Text('Keluar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onRestart();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Main Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6A9F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResultStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}