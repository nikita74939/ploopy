import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ploopy/core/theme/app_colors.dart';

class OcrEmptyState extends StatelessWidget {
  final VoidCallback onStart;

  const OcrEmptyState({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.greyLighter,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.text_fields_rounded,
                size: 40,
                color: AppColors.greyHint,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada hasil',
              style: GoogleFonts.robotoMono(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ambil foto atau pilih gambar untuk\nmengubah teks menjadi teks aktif',
              textAlign: TextAlign.center,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                color: AppColors.greyText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onStart,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.document_scanner_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Ambil Gambar',
                      style: GoogleFonts.robotoMono(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}