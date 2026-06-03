import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Warna yang tersedia untuk jadwal
const List<Map<String, dynamic>> kScheduleColors = [
  {'value': '0xFFFF7600', 'label': 'Utama'},
  {'value': '0xFFF5A623', 'label': 'Oranye'},
  {'value': '0xFF9CCC65', 'label': 'Hijau'},
  {'value': '0xFFFFEE58', 'label': 'Kuning'},
  {'value': '0xFF42A5F5', 'label': 'Biru'},
  {'value': '0xFFEF5350', 'label': 'Merah'},
  {'value': '0xFFAB47BC', 'label': 'Ungu'},
  {'value': '0xFF26C6DA', 'label': 'Tosca'},
  {'value': '0xFFFF7043', 'label': 'Merah-Oranye'},
  {'value': '0xFF66BB6A', 'label': 'Hijau Tua'},
  {'value': '0xFF1E1E1E', 'label': 'Hitam'},
];

class ColorPickerWidget extends StatelessWidget {
  final String selectedColor;
  final void Function(String) onColorSelected;

  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: kScheduleColors.map((c) {
        final colorVal = c['value'] as String;
        final color = Color(int.parse(colorVal));
        final isSelected = selectedColor == colorVal;
        return GestureDetector(
          onTap: () => onColorSelected(colorVal),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.border : Colors.transparent,
                width: isSelected ? 3 : 0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
