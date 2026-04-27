import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'todo_filter_tabs.dart';

class TodoEmptyState extends StatelessWidget {
  final TodoFilter filter;

  const TodoEmptyState({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    final (emoji, title, subtitle) = _getContent();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  (String, String, String) _getContent() {
    switch (filter) {
      case TodoFilter.all:
        return ('📝', 'Belum ada tugas', 'Tap + untuk bikin tugas pertamamu!');
      case TodoFilter.today:
        return ('🎉', 'Hari ini free!', 'Nggak ada tugas untuk hari ini');
      case TodoFilter.upcoming:
        return ('⏰', 'Belum ada rencana', 'Atur tugas untuk hari-hari mendatang');
      case TodoFilter.done:
        return ('💪', 'Belum ada yang selesai', 'Yuk mulai kerjakan tugasmu!');
    }
  }
}