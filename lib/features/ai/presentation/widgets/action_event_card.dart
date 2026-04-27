import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActionEventCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ActionEventCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow(
          icon: Icons.event_rounded,
          color: const Color(0xFFFF8C42),
          label: 'Event',
          value: data['title'] as String? ?? '-',
        ),
        if (data['description'] != null && (data['description'] as String).isNotEmpty)
          _buildRow(
            icon: Icons.notes_rounded,
            color: Colors.grey.shade600,
            label: 'Deskripsi',
            value: data['description'] as String,
          ),
        _buildRow(
          icon: Icons.calendar_today_rounded,
          color: const Color(0xFF4D96FF),
          label: 'Tanggal',
          value: _formatDate(data['date'] as String?),
        ),
        _buildRow(
          icon: Icons.access_time_rounded,
          color: const Color(0xFFFF8C42),
          label: 'Waktu',
          value: data['time'] as String? ?? '-',
        ),
        if (data['location'] != null)
          _buildRow(
            icon: Icons.location_on_rounded,
            color: const Color(0xFFFF6B6B),
            label: 'Lokasi',
            value: data['location'] as String,
          ),
        if (data['category'] != null)
          _buildRow(
            icon: Icons.category_rounded,
            color: const Color(0xFFB79CED),
            label: 'Kategori',
            value: data['category'] as String,
          ),
      ],
    );
  }

  Widget _buildRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;
      final year = parts[0];
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '$day ${months[month - 1]} $year';
    } catch (_) {
      return dateStr;
    }
  }
}