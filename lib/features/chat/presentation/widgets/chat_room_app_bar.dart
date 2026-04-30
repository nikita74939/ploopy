// chat/presentation/widgets/chat_room_app_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ChatRoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Map<String, dynamic> chat;

  const ChatRoomAppBar({super.key, required this.chat});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final color = chat['color'] as Color;
    final isGroup = chat['isGroup'] == true;

    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.greyBorder, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.black,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Avatar
              _buildAvatar(color, isGroup),
              const SizedBox(width: 12),
              // Name (centered vertically)
              Expanded(
                child: Text(
                  chat['name'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Action icons (no background)
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.call_outlined,
                  color: AppColors.black,
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.videocam_outlined,
                  color: AppColors.black,
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.black,
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Color color, bool isGroup) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
      ),
      alignment: Alignment.center,
      child:
          isGroup
              ? Text(
                chat['avatar'] as String,
                style: const TextStyle(fontSize: 18),
              )
              : Text(
                chat['avatar'] as String,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
    );
  }
}
