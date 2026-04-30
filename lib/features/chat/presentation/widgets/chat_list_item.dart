// chat/presentation/widgets/chat_list_item.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ChatListItem extends StatelessWidget {
  final Map<String, dynamic> chat;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = chat['color'] as Color;
    final isGroup = chat['isGroup'] == true;
    final isPinned = chat['isPinned'] == true;
    final isMuted = chat['isMuted'] == true;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: AppColors.white,
        child: Row(
          children: [
            // Avatar
            _buildAvatar(color, isGroup),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isPinned)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.push_pin_outlined,
                            size: 14,
                            color: AppColors.grey,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          chat['name'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: chat['unread'] as int > 0
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildTime(chat),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isMuted)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.notifications_off_outlined,
                            size: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          chat['lastMessage'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: (chat['unread'] as int) > 0
                                ? AppColors.black
                                : AppColors.grey,
                            fontWeight: (chat['unread'] as int) > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if ((chat['unread'] as int) > 0) _buildUnreadBadge(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Color color, bool isGroup) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        chat['avatar'] as String,
        style: GoogleFonts.inter(
          fontSize: isGroup ? 20 : 18,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTime(Map<String, dynamic> chat) {
    final hasUnread = (chat['unread'] as int) > 0;

    return Text(
      chat['time'] as String,
      style: GoogleFonts.inter(
        fontSize: 11,
        color: hasUnread ? AppColors.black : AppColors.grey,
        fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _buildUnreadBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '${chat['unread']}',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }
}