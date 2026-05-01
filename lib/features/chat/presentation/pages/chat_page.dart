import 'package:flutter/material.dart';
import '../../../../core/constants/chat_dummy_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/chat_list_item.dart';
import 'chat_room_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: ChatDummyData.chats.length,
                separatorBuilder:
                    (_, __) => Container(
                      height: 1,
                      color: AppColors.greyBorder,
                    ),
                itemBuilder:
                    (_, i) => ChatListItem(
                      chat: ChatDummyData.chats[i],
                      onTap:
                          () => _openChatRoom(context, ChatDummyData.chats[i]),
                    ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  void _openChatRoom(BuildContext context, Map<String, dynamic> chat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatRoomPage(chat: chat)),
    );
  }

  //   Widget _buildHeader() {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
  //     child: Row(
  //       children: [
  //         IconButton(
  //           icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
  //           color: AppColors.black,
  //           onPressed: () => Navigator.pop(context),
  //         ),
  //         Expanded(
  //           child: Text(
  //             'Chat',
  //             style: AppTextStyles.heading.copyWith(fontSize: 18),
  //           ),
  //         ),
  //         Container(
  //           width: 32,
  //           height: 32,
  //           decoration: BoxDecoration(
  //             color: AppColors.greyLight,
  //             borderRadius: BorderRadius.circular(8),
  //             border: Border.all(color: AppColors.greyBorder),
  //           ),
  //           child: const Icon(
  //             Icons.filter_list_rounded,
  //             size: 16,
  //             color: AppColors.grey,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('chat', style: AppTextStyles.heading),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: const Icon(
              Icons.filter_list_rounded,
              size: 16,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      color: AppColors.background,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.greyBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              size: 16,
              color: AppColors.greyHint,
            ),
            const SizedBox(width: 10),
            Text('cari chat...', style: AppTextStyles.hint),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: const Icon(
            Icons.edit_outlined,
            color: AppColors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}