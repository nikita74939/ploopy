import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatRoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Map<String, dynamic> chat;

  const ChatRoomAppBar({super.key, required this.chat});

  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context) {
    final color = chat['color'] as Color;
    final isGroup = chat['isGroup'] == true;
    final isTyping = chat['isTyping'] as bool? ?? false;

    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: Colors.black87,
                onPressed: () => Navigator.pop(context),
              ),
              _buildAvatar(color, isGroup),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat['name'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      isTyping ? 'mengetik...' : 'aktif 2 menit lalu',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.videocam_rounded),
                color: Colors.grey.shade600,
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.call_rounded),
                color: Colors.grey.shade600,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Color color, bool isGroup) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      alignment: Alignment.center,
      child: isGroup
          ? Text(
              chat['avatar'] as String,
              style: const TextStyle(fontSize: 18),
            )
          : Text(
              chat['avatar'] as String,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
    );
  }
}