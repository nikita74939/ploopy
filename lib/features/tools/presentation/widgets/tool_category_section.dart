import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ploopy/core/theme/app_colors.dart';
import 'tool_card.dart';

class ToolCategorySection extends StatelessWidget {
  final Map<String, dynamic> category;
  final Function(Map<String, dynamic>) onToolTap;

  const ToolCategorySection({
    super.key,
    required this.category,
    required this.onToolTap,
  });

  @override
  Widget build(BuildContext context) {
    final tools = category['tools'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        ...tools.map((t) {
          final tool = t as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ToolCard(
              tool: tool,
              onTap: () => onToolTap(tool),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category['title'] as String,
            style: GoogleFonts.robotoMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            category['description'] as String,
            style: GoogleFonts.robotoMono(
              fontSize: 11,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }
}