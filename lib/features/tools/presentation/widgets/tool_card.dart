import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final color = tool['color'] as Color;
    final available = tool['available'] as bool;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Row(
            children: [
              _buildIcon(color, available),
              const SizedBox(width: 14),
              Expanded(child: _buildInfo(available)),
              _buildTrailing(available, color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color, bool available) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: available ? color.withOpacity(0.12) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        tool['icon'] as IconData,
        color: available ? color : Colors.grey.shade400,
        size: 22,
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
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: available ? Colors.black87 : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          tool['description'] as String,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTrailing(bool available, Color color) {
    if (!available) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Soon',
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
      );
    }

    return Icon(
      Icons.chevron_right_rounded,
      size: 22,
      color: Colors.grey.shade300,
    );
  }
}