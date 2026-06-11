import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/timezone_data.dart';
import '../../../../core/theme/app_colors.dart';

class TimezoneCard extends StatelessWidget {
  final String label;
  final String timezoneId;
  final DateTime dateTime;
  final VoidCallback onTimezoneTap;
  final bool highlighted;

  const TimezoneCard({
    super.key,
    required this.label,
    required this.timezoneId,
    required this.dateTime,
    required this.onTimezoneTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final tz = TimezoneData.getById(timezoneId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primary.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlighted
              ? AppColors.primary.withOpacity(0.3)
              : Colors.grey.shade100,
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
              const Spacer(),
              if (highlighted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'SUMBER',
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTimezoneSelector(tz),
              const SizedBox(width: 12),
              Expanded(child: _buildTimeDisplay()),
            ],
          ),
          const SizedBox(height: 8),
          _buildDateDisplay(),
        ],
      ),
    );
  }

  Widget _buildTimezoneSelector(Map<String, String>? tz) {
    return GestureDetector(
      onTap: onTimezoneTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public_rounded, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tz?['city'] ?? '---',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'UTC${tz?['offset'] ?? ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    final s = dateTime.second.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$h:$m',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                height: 1,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              ':$s',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
                height: 1,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              period,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateDisplay() {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final dayName = days[dateTime.weekday - 1];
    final dateStr =
        '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';

    return Row(
      children: [
        Icon(
          Icons.calendar_today_rounded,
          size: 11,
          color: Colors.grey.shade400,
        ),
        const SizedBox(width: 6),
        Text(
          '$dayName, $dateStr',
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
