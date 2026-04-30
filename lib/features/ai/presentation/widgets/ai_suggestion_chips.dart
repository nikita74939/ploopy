import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AiSuggestionChips extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const AiSuggestionChips({super.key, required this.onSelected});

  static const List<_Suggestion> _suggestions = [
    _Suggestion(
      icon: Icons.check_circle_outline,
      title: 'Bikin to-do',
      prompt: 'Besok jam 7 pagi ingetin aku olahraga 30 menit',
    ),
    _Suggestion(
      icon: Icons.event_outlined,
      title: 'Schedule event',
      prompt:
          'Schedule belajar kelompok hari Sabtu jam 2 siang di perpustakaan',
    ),
    _Suggestion(
      icon: Icons.edit_note_outlined,
      title: 'Buat post',
      prompt:
          'Bikinin caption buat post aku: hari ini aku streak 7 hari belajar!',
    ),
    _Suggestion(
      icon: Icons.timer_outlined,
      title: 'Mulai pomodoro',
      prompt: 'Mulai pomodoro 25 menit buat belajar matematika',
    ),
    _Suggestion(
      icon: Icons.lightbulb_outline,
      title: 'Tanya konsep',
      prompt: 'Jelasin integral parsial dengan contoh',
    ),
    _Suggestion(
      icon: Icons.trending_up_rounded,
      title: 'Motivasi',
      prompt: 'Aku lagi down, kasih motivasi dong!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 10),
          child: Text('Mulai dari sini', style: AppTextStyles.small),
        ),
        SizedBox(
          height: 54,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final suggestion = _suggestions[i];
              return Material(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => onSelected(suggestion.prompt),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.greyBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(suggestion.icon, size: 16, color: AppColors.black),
                        const SizedBox(width: 8),
                        Text(
                          suggestion.title,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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

class _Suggestion {
  final IconData icon;
  final String title;
  final String prompt;

  const _Suggestion({
    required this.icon,
    required this.title,
    required this.prompt,
  });
}
