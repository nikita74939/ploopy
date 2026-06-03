import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart' show AppStyle;
import '../../../../core/theme/app_colors.dart';

const List<Map<String, dynamic>> kScheduleIcons = [
  {'value': 'event', 'icon': Icons.event},
  {'value': 'school', 'icon': Icons.school},
  {'value': 'work', 'icon': Icons.work},
  {'value': 'book', 'icon': Icons.menu_book},
  {'value': 'sports', 'icon': Icons.sports},
  {'value': 'music', 'icon': Icons.music_note},
  {'value': 'food', 'icon': Icons.restaurant},
  {'value': 'health', 'icon': Icons.favorite},
  {'value': 'travel', 'icon': Icons.flight},
  {'value': 'social', 'icon': Icons.people},
  {'value': 'game', 'icon': Icons.sports_esports},
  {'value': 'meeting', 'icon': Icons.groups},
];

class IconPickerWidget extends StatelessWidget {
  final String selectedIcon;
  final void Function(String) onIconSelected;

  const IconPickerWidget({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: kScheduleIcons.map((item) {
        final value = item['value'] as String;
        final icon = item['icon'] as IconData;
        final isSelected = selectedIcon == value;

        return GestureDetector(
          onTap: () => onIconSelected(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.textMain : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: isSelected ? AppStyle.borderWidth : 2,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: AppColors.border,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
          ),
        );
      }).toList(),
    );
  }
}
