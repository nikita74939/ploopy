import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class UrgentTaskBanner extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap;

  const UrgentTaskBanner({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = item['color'] as Color;
    final isDone = item['done'] as bool? ?? false;
    final due = item['due'] as String? ?? '';

    // Determine due color
    Color dueColor;
    Color dueBg;
    if (due == 'Kemarin') {
      dueColor = AppColors.black;
      dueBg = AppColors.greyLight;
    } else if (due == 'Besok') {
      dueColor = AppColors.greyText;
      dueBg = AppColors.greyLighter;
    } else {
      dueColor = AppColors.primary;
      dueBg = AppColors.primaryLight;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDone ? AppColors.greyLighter : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isDone
                    ? AppColors.greyBorder
                    : dueColor.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDone ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDone ? color : AppColors.greyBorder,
                  width: 1.8,
                ),
              ),
              child:
                  isDone
                      ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                      : null,
            ),
            const SizedBox(width: 10),
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    isDone
                        ? AppColors.greyLight
                        : color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item['icon'] as IconData,
                color: isDone ? Colors.grey.shade400 : color,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['title'] as String,
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDone ? AppColors.greyHint : AppColors.black,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['subject'] as String,
                    style: GoogleFonts.robotoMono(
                      fontSize: 10,
                      color: AppColors.greyText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Due badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: dueBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                due,
                style: GoogleFonts.robotoMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: dueColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
