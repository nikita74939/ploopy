// lib/features/study_desk/presentation/widgets/focus_session_timer.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/study_session.dart';

class FocusSessionTimer extends StatelessWidget {
  final String sessionTime;
  final StudyState state;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final String emoji;
  final String mood;

  const FocusSessionTimer({
    super.key,
    required this.sessionTime,
    required this.state,
    required this.onStart,
    required this.onPause,
    required this.emoji,
    required this.mood,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        children: [
          // Header: focusing | emoji
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    state == StudyState.focusing
                        ? Icons.timer_rounded
                        : Icons.timer_outlined,
                    color:
                        state == StudyState.focusing
                            ? AppColors.primary
                            : AppColors.greyHint,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'focusing',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          state == StudyState.focusing
                              ? AppColors.black
                              : AppColors.greyHint,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Timer display | Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Session timer
              Text(
                sessionTime,
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color:
                      state == StudyState.focusing
                          ? AppColors.black
                          : AppColors.greyHint,
                  letterSpacing: 0,
                ),
              ),

              // Action button (start / pause)
              _buildActionButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final isFocusing = state == StudyState.focusing;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (isFocusing) {
          onPause();
        } else {
          onStart();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isFocusing ? AppColors.greyLighter : AppColors.black,
          borderRadius: BorderRadius.circular(10),
          border: isFocusing ? Border.all(color: AppColors.greyBorder) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFocusing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 20,
              color: isFocusing ? AppColors.black : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              isFocusing ? 'pause' : 'start',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isFocusing ? AppColors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
