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
      backgroundColor: Colors.grey.shade50,
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
                    (_, __) => Divider(
                      height: 1,
                      color: Colors.grey.shade100,
                      indent: 80,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Chat',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: Colors.white,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 18, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Text(
              'Cari chat...',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade500,
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
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}
