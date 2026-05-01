import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.black : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isMe ? 12 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 12),
                    ),
                    border: isMe
                        ? null
                        : Border.all(color: AppColors.greyBorder, width: 1),
                  ),
                  child: Text(
                    text,
                    style: AppTextStyles.body.copyWith(
                      color: isMe ? AppColors.white : AppColors.black,
                      height: 1.5,
                    ),
                  ),
                ),
                if (showTime) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(time, style: AppTextStyles.caption),
                        if (isMe) ...[
                          const SizedBox(width: 3),
                          Icon(
                            read
                                ? Icons.done_all_rounded
                                : Icons.done_rounded,
                            size: 12,
                            color: AppColors.greyHint,
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