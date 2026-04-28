import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class OcrEmptyState extends StatelessWidget {
  final VoidCallback onStart;

  const OcrEmptyState({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('🔍', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 20),
            Text(
              'Ekstrak Teks dari Gambar',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Foto atau upload gambar, biar AI\nubah jadi teks yang bisa diedit!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.text_fields_rounded, size: 18),
              label: Text(
                'Mulai Ekstrak',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChips() {
    final features = [
      {'emoji': '📷', 'label': 'Kamera'},
      {'emoji': '🖼️', 'label': 'Gallery'},
      {'emoji': '🤖', 'label': 'AI On-device'},
      {'emoji': '📋', 'label': 'Copy & Share'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: features.map((f) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(f['emoji']!, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                f['label']!,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}