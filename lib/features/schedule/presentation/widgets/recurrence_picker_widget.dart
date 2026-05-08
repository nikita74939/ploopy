import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/doodle_container.dart';

const List<Map<String, String>> kRecurrenceOptions = [
  {'value': 'None', 'label': 'Tidak ada'},
  {'value': 'Daily', 'label': 'Setiap Hari'},
  {'value': 'Weekly', 'label': 'Setiap Minggu'},
  {'value': 'Monthly', 'label': 'Setiap Bulan'},
];

class RecurrencePickerWidget extends StatelessWidget {
  final String selectedRecurrence;
  final DateTime? recurrenceEnd;
  final void Function(String) onRecurrenceChanged;
  final void Function(DateTime?) onRecurrenceEndChanged;

  const RecurrencePickerWidget({
    super.key,
    required this.selectedRecurrence,
    required this.recurrenceEnd,
    required this.onRecurrenceChanged,
    required this.onRecurrenceEndChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: kRecurrenceOptions.map((opt) {
            final isSelected = selectedRecurrence == opt['value'];
            return GestureDetector(
              onTap: () {
                onRecurrenceChanged(opt['value']!);
                if (opt['value'] == 'None') {
                  onRecurrenceEndChanged(null);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
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
                            offset: Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  opt['label']!,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textMain,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        if (selectedRecurrence != 'None') ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate:
                    recurrenceEnd ??
                    DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
                helpText: 'Pilih batas perulangan',
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                    ),
                  ),
                  child: child!,
                ),
              );
              onRecurrenceEndChanged(picked);
            },
            child: DoodleContainer(
              color: AppColors.yellowAccent.withOpacity(0.3),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_repeat_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Batas Perulangan',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          recurrenceEnd != null
                              ? DateFormat(
                                  'd MMMM yyyy',
                                  'id_ID',
                                ).format(recurrenceEnd!)
                              : 'Tanpa batas',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (recurrenceEnd != null)
            TextButton.icon(
              onPressed: () => onRecurrenceEndChanged(null),
              icon: const Icon(Icons.clear, size: 14, color: Colors.grey),
              label: Text(
                'Hapus batas',
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
              ),
            ),
        ],
      ],
    );
  }
}
