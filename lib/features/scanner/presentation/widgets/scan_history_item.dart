import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/scanned_doc_model.dart';

class ScanHistoryItem extends StatelessWidget {
  final ScannedDoc doc;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ScanHistoryItem({
    super.key,
    required this.doc,
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Row(
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
        width: 60,
        height: 80,
        color: Colors.grey.shade100,
        child: doc.imagePaths.isNotEmpty
            ? Image.file(
                File(doc.imagePaths.first),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    color: Colors.grey,
                  ),
                ),
              )
            : const Center(
                child: Icon(Icons.description_rounded, color: Colors.grey),
              ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          doc.title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.description_rounded,
              size: 11,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 4),
            Text(
              '${doc.pageCount} halaman',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.schedule_rounded,
              size: 11,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 4),
            Text(
              _formatDate(doc.scannedAt),
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (doc.pdfPath != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 10,
                  color: Colors.red.shade600,
                ),
                const SizedBox(width: 3),
                Text(
                  'PDF',
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
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
                'Lihat',
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