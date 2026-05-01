import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

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
    final hasUnread = (chat['unread'] as int) > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: AppColors.white,
        child: Row(
          children: [
            _buildAvatar(color, isGroup),
            const SizedBox(width: 12),
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
                            size: 12,
                            color: AppColors.greyHint,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          chat['name'] as String,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        chat['time'] as String,
                        style: AppTextStyles.caption.copyWith(
                          color: hasUnread ? AppColors.black : AppColors.greyHint,
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isMuted)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.volume_off_outlined,
                            size: 11,
                            color: AppColors.greyHint,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          chat['lastMessage'] as String,
                          style: AppTextStyles.caption.copyWith(
                            color: hasUnread ? AppColors.black : AppColors.greyText,
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) _buildUnreadBadge(),
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
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.greyBorder, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        chat['avatar'] as String,
        style: AppTextStyles.body.copyWith(
          fontSize: isGroup ? 18 : 16,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildUnreadBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${chat['unread']}',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}