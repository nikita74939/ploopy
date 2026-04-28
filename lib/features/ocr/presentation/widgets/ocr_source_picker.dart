import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum OcrSource { camera, gallery }

class OcrSourcePicker extends StatelessWidget {
  const OcrSourcePicker({super.key});

  static Future<OcrSource?> show(BuildContext context) {
    return showModalBottomSheet<OcrSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const OcrSourcePicker(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSourceCard(
                      context: context,
                      icon: Icons.camera_alt_rounded,
                      emoji: '📷',
                      title: 'Kamera',
                      subtitle: 'Foto langsung',
                      color: const Color(0xFFFF6B6B),
                      source: OcrSource.camera,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSourceCard(
                      context: context,
                      icon: Icons.photo_library_rounded,
                      emoji: '🖼️',
                      title: 'Galeri',
                      subtitle: 'Pilih dari HP',
                      color: const Color(0xFF4D96FF),
                      source: OcrSource.gallery,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Sumber Gambar',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          Text(
            'Gambar akan diproses untuk ekstrak teks',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceCard({
    required BuildContext context,
    required IconData icon,
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required OcrSource source,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => Navigator.pop(context, source),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}