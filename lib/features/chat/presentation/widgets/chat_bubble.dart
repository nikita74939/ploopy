// chat/presentation/widgets/chat_bubble.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool showTime;

  const ChatBubble({
    super.key,
    required this.message,
    this.showTime = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message['isMe'] as bool;
    final text = message['text'] as String;
    final time = message['time'] as String;
    final read = message['read'] as bool;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.74,
            ),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.black : AppColors.greyLight,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    border: isMe ? null : Border.all(color: AppColors.greyBorder, width: 1),
                  ),
                  child: Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isMe ? AppColors.white : AppColors.black,
                      height: 1.4,
                    ),
                  ),
                ),
                if (showTime) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.grey,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            read ? Icons.done_all_rounded : Icons.done_rounded,
                            size: 12,
                            color: read ? AppColors.black : AppColors.grey,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}