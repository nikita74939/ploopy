import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActionPostCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ActionPostCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final content = data['content'] as String? ?? '';
    final mood = data['mood'] as String? ?? '😊';
    final achievements = (data['achievements'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPreviewPost(content, mood, achievements),
        const SizedBox(height: 10),
        _buildMetadata(achievements),
      ],
    );
  }

  Widget _buildPreviewPost(String content, String mood, List achievements) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE89E),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(mood, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (achievements.isNotEmpty) ...[
                  Row(
                    children: achievements.take(5).map<Widget>((a) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            a.toString(),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  content,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(List achievements) {
    return Row(
      children: [
        Icon(
          Icons.public_rounded,
          size: 12,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 4),
        Text(
          'Akan di-post ke feed kamu',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
        const Spacer(),
        if (achievements.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '🏆 ${achievements.length} achievement',
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.amber.shade700,
              ),
            ),
          ),
      ],
    );
  }
}