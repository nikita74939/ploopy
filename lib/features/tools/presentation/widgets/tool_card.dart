import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ploopy/core/theme/app_colors.dart';

class ToolCard extends StatelessWidget {
  final Map<String, dynamic> tool;
  final VoidCallback onTap;

  const ToolCard({
    super.key,
    required this.tool,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final available = tool['available'] as bool;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.greyBorder, width: 1),
          ),
          child: Row(
            children: [
              _buildIcon(available),
              const SizedBox(width: 14),
              Expanded(child: _buildInfo(available)),
              _buildTrailing(available),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool available) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: available ? AppColors.greyLight : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        tool['icon'] as IconData,
        color: available ? AppColors.black : Colors.grey.shade400,
        size: 20,
      ),
    );
  }

  Widget _buildInfo(bool available) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          tool['label'] as String,
          style: GoogleFonts.robotoMono(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: available ? AppColors.black : AppColors.greyHint,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          tool['description'] as String,
          style: GoogleFonts.robotoMono(
            fontSize: 11,
            color: AppColors.greyText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTrailing(bool available) {
    if (!available) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Soon',
          style: GoogleFonts.robotoMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.greyText,
          ),
        ),
      );
    }

    return Icon(
      Icons.chevron_right_rounded,
      size: 22,
      color: AppColors.greyBorder,
    );
  }
}