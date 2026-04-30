import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ActionTodoCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ActionTodoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow(
          icon: Icons.check_circle_outline,
          label: 'Task',
          value: data['title'] as String? ?? '-',
        ),
        if (data['description'] != null &&
            (data['description'] as String).isNotEmpty)
          _buildRow(
            icon: Icons.notes_outlined,
            label: 'Deskripsi',
            value: data['description'] as String,
          ),
        _buildRow(
          icon: Icons.calendar_today_outlined,
          label: 'Tanggal',
          value: _formatDate(data['date'] as String?),
        ),
        _buildRow(
          icon: Icons.access_time_outlined,
          label: 'Waktu',
          value: data['time'] as String? ?? '-',
        ),
        if (data['duration'] != null)
          _buildRow(
            icon: Icons.timer_outlined,
            label: 'Durasi',
            value: '${data['duration']} menit',
          ),
        _buildPriority(),
      ],
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _buildIcon(icon),
          const SizedBox(width: 10),
          SizedBox(width: 70, child: Text(label, style: AppTextStyles.caption)),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriority() {
    final priority = data['priority'] as String? ?? 'medium';
    late final String label;

    switch (priority.toLowerCase()) {
      case 'high':
        label = 'Tinggi';
        break;
      case 'low':
        label = 'Rendah';
        break;
      default:
        label = 'Sedang';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          _buildIcon(Icons.flag_outlined),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text('Prioritas', style: AppTextStyles.caption),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: Text(
              label,
              style: AppTextStyles.small.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyBorder),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 14, color: AppColors.black),
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
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Ags',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '$day ${months[month - 1]} $year';
    } catch (_) {
      return dateStr;
    }
  }
}
