import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ChatRoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Map<String, dynamic> chat;

  const ChatRoomAppBar({super.key, required this.chat});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.greyBorder, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.greyBorder),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.black,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildAvatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat['name'] as String,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'online',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              _buildIconButton(Icons.call_outlined),
              _buildIconButton(Icons.videocam_outlined),
              _buildIconButton(Icons.more_vert),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.greyBorder),
      ),
      alignment: Alignment.center,
      child: Text(
        chat['avatar'] as String,
        style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.only(left: 4),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: AppColors.grey, size: 18),
        padding: EdgeInsets.zero,
      ),
    );
  }
}