// chat/presentation/widgets/chat_date_separator.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ChatDateSeparator extends StatelessWidget {
  final String date;

  const ChatDateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.greyBorder),
          ),
          child: Text(
            date,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}