import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/ocr_result_model.dart';

class OcrHistoryItem extends StatelessWidget {
  final OcrResult result;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const OcrHistoryItem({
    super.key,
    required this.result,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(),
              const SizedBox(width: 12),
              Expanded(child: _buildContent()),
              _buildMoreButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 50,
        height: 50,
        color: Colors.grey.shade100,
        child: result.imagePath != null && File(result.imagePath!).existsSync()
            ? Image.file(
                File(result.imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackIcon(),
              )
            : _fallbackIcon(),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      color: const Color(0xFFE0F2FE),
      alignment: Alignment.center,
      child: const Text('📝', style: TextStyle(fontSize: 22)),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result.title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          result.preview.isEmpty ? '(Teks kosong)' : result.preview,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildStat(
              icon: Icons.format_list_bulleted_rounded,
              text: '${result.wordCount} kata',
            ),
            const SizedBox(width: 10),
            _buildStat(
              icon: Icons.schedule_rounded,
              text: _formatDate(result.createdAt),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStat({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 10, color: Colors.grey.shade500),
        const SizedBox(width: 3),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 9,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.more_vert_rounded,
        color: Colors.grey.shade600,
        size: 20,
      ),
      onPressed: () => _showOptions(context),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.visibility_rounded),
              title: Text(
                'Lihat Hasil',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              onTap: () {
                Navigator.pop(context);
                onTap();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red.shade400,
              ),
              title: Text(
                'Hapus',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.red.shade400,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    if (diff.inDays < 7) return '${diff.inDays}h lalu';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}