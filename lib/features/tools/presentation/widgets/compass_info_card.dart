import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class CompassInfoCard extends StatelessWidget {
  final double heading;

  const CompassInfoCard({super.key, required this.heading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF3E9), Color(0xFFFFE8D6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildHeadingDisplay(),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 44,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildDirectionInfo()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeadingDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Heading',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              heading.toStringAsFixed(0),
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                height: 1,
              ),
            ),
            Text(
              '°',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Arah',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              _getDirectionName(),
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${_getDirectionCode()})',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getDirectionName() {
    if (heading >= 337.5 || heading < 22.5) return 'Utara';
    if (heading >= 22.5 && heading < 67.5) return 'Timur Laut';
    if (heading >= 67.5 && heading < 112.5) return 'Timur';
    if (heading >= 112.5 && heading < 157.5) return 'Tenggara';
    if (heading >= 157.5 && heading < 202.5) return 'Selatan';
    if (heading >= 202.5 && heading < 247.5) return 'Barat Daya';
    if (heading >= 247.5 && heading < 292.5) return 'Barat';
    if (heading >= 292.5 && heading < 337.5) return 'Barat Laut';
    return '-';
  }

  String _getDirectionCode() {
    if (heading >= 337.5 || heading < 22.5) return 'N';
    if (heading >= 22.5 && heading < 67.5) return 'NE';
    if (heading >= 67.5 && heading < 112.5) return 'E';
    if (heading >= 112.5 && heading < 157.5) return 'SE';
    if (heading >= 157.5 && heading < 202.5) return 'S';
    if (heading >= 202.5 && heading < 247.5) return 'SW';
    if (heading >= 247.5 && heading < 292.5) return 'W';
    if (heading >= 292.5 && heading < 337.5) return 'NW';
    return '-';
  }
}