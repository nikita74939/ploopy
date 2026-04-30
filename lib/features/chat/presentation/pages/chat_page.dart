// chat/presentation/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/chat_dummy_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/chat_list_item.dart';
import 'chat_room_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: ChatDummyData.chats.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: AppColors.greyBorder,
                  indent: 76,
                ),
                itemBuilder: (_, i) => ChatListItem(
                  chat: ChatDummyData.chats[i],
                  onTap: () => _openChatRoom(context, ChatDummyData.chats[i]),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildNewChatFab(),
    );
  }

  void _openChatRoom(BuildContext context, Map<String, dynamic> chat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatRoomPage(chat: chat)),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.greyBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Chat',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: AppColors.white,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.greyBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 18, color: AppColors.grey),
            const SizedBox(width: 10),
            Text(
              'Cari chat...',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewChatFab() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, right: 4),
      child: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.black,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.edit_outlined, color: AppColors.white, size: 22),
      ),
    );
  }
}