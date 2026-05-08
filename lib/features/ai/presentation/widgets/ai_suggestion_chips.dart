import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';

class AiSuggestionChips extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const AiSuggestionChips({super.key, required this.onSelected});

  // Ganti _suggestions dengan ini:
static const List<Map<String, String>> _suggestions = [
  {
    'emoji': '✅',
    'title': 'Bikin to-do',
    'prompt': 'Besok jam 7 pagi ingetin aku olahraga 30 menit',
  },
  {
    'emoji': '📅',
    'title': 'Schedule event',
    'prompt': 'Schedule belajar kelompok hari Sabtu jam 2 siang di perpustakaan',
  },
  {
    'emoji': '📝',
    'title': 'Buat post',
    'prompt': 'Bikinin caption buat post aku: hari ini aku streak 7 hari belajar!',
  },
  {
    'emoji': '⏱️',
    'title': 'Mulai pomodoro',
    'prompt': 'Mulai pomodoro 25 menit buat belajar matematika',
  },
  {
    'emoji': '💡',
    'title': 'Tanya konsep',
    'prompt': 'Jelasin integral parsial dengan contoh',
  },
  {
    'emoji': '🎯',
    'title': 'Motivasi',
    'prompt': 'Aku lagi down, kasih motivasi dong!',
  },
];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 10),
          child: Text(
            '✨ Mulai dari sini',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final s = _suggestions[i];
              return GestureDetector(
                onTap: () => onSelected(s['prompt']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(s['emoji']!, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        s['title']!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}