// lib/features/study_desk/presentation/widgets/study_timer_display.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class StudyTimerDisplay extends StatelessWidget {
  final String totalTime;
  final String sessionTime;
  final bool isFocusing;
  final VoidCallback onToolsTap;

  const StudyTimerDisplay({
    super.key,
    required this.totalTime,
    required this.sessionTime,
    required this.isFocusing,
    required this.onToolsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Main timer (total waktu belajar)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'belajar',
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.greyText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  totalTime,
                  style: GoogleFonts.robotoMono(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),

          // Tools icon button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onToolsTap();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.greyBorder),
              ),
              child: const Icon(
                Icons.construction_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}