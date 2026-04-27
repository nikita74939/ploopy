import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActionTodoCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ActionTodoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow(
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF6BCB77),
          label: 'Task',
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
        if (data['duration'] != null)
          _buildRow(
            icon: Icons.timer_rounded,
            color: const Color(0xFFB79CED),
            label: 'Durasi',
            value: '${data['duration']} menit',
          ),
        _buildPriority(),
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
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriority() {
    final priority = data['priority'] as String? ?? 'medium';
    Color color;
    String label;

    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red.shade400;
        label = 'Tinggi';
        break;
      case 'low':
        color = Colors.green.shade400;
        label = 'Rendah';
        break;
      default:
        color = Colors.orange.shade400;
        label = 'Sedang';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.flag_rounded, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(
              'Prioritas',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
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