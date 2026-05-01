// lib/features/study_desk/presentation/widgets/ai_insight_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class AiInsightCard extends StatelessWidget {
  final String insight;
  final VoidCallback? onRefresh;

  const AiInsightCard({super.key, required this.insight, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Ploopy Insight',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const Spacer(),
              if (onRefresh != null)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onRefresh?.call();
                  },
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: AppColors.greyText,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Insight text
          Text(
            insight,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.greyText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
